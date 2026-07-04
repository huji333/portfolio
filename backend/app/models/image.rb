class Image < ApplicationRecord
  include RankedModel
  include CdnAttachedFile

  ranks :row_order
  THUMBNAIL_LIMIT = [960, 960].freeze
  DISPLAY_LIMIT = [1920, 1920].freeze

  has_many :image_categories, dependent: :destroy
  has_many :categories, through: :image_categories
  belongs_to :camera, optional: true
  belongs_to :lens, optional: true

  has_one_attached :file, dependent: :purge_later

  # 公開に必要な項目の単一ソース。バリデーションと publishable?
  # （UI で公開ボタンを出すかの判定）を両方ここから導出する。
  PUBLISH_REQUIREMENTS = %i[title taken_at].freeze

  validates :file, presence: true
  # Records exist as drafts first (bulk ingest); title/taken_at are
  # publish-quality requirements, not record-existence requirements.
  PUBLISH_REQUIREMENTS.each { |attr| validates attr, presence: true, if: :is_published? }
  validates :is_published, inclusion: { in: [true, false] }

  scope :published, -> { where(is_published: true) }
  scope :draft, -> { where(is_published: false) }
  scope :uncurated, -> { draft.where(title: [nil, ""]) }
  scope :ordered_for_gallery, -> { order(row_order: :asc, id: :asc) }

  validate :taken_at_is_in_the_past

  before_validation :fill_metadata_from_exif, on: :create

  def category_ids=(ids)
    super(Array(ids).compact_blank)
  end

  def publishable?
    PUBLISH_REQUIREMENTS.all? { |attr| public_send(attr).present? }
  end

  # 並び替え画面は公開画像のみを表示するため、ドロップ位置は「公開リスト内の index」で
  # 届く。これを全画像共有の row_order 空間での position に変換する。ドロップ位置の次に
  # 来る公開画像の直前へ、末尾なら最後の公開画像の直後へ挿入する（末尾より後ろの下書きは
  # 追い越さない）。全画像が公開のときは index と一致する。
  def self.published_index_to_row_order_position(image, published_index)
    others = where.not(id: image.id)
    published = others.published.rank(:row_order).to_a
    if (successor = published[published_index])
      others.where(row_order: ...successor.row_order).count
    elsif (last = published.last)
      others.where(row_order: ..last.row_order).count
    else
      0
    end
  end

  def self.filter_by_categories(category_ids)
    return all if category_ids.blank?

    where(id: ImageCategory.where(category_id: category_ids).select(:image_id))
  end

  def self.for_gallery(category_ids: nil, cursor: nil, limit: 20)
    scope = published
            .filter_by_categories(category_ids)
            .with_attached_file
            .includes(:camera, :lens)

    if cursor.present?
      parts = cursor.split(",")
      if parts.size == 2 && parts.all? { |p| p.match?(/\A-?\d+\z/) }
        row_order_val, id_val = parts.map(&:to_i)
        scope = scope.where("(row_order, id) > (?, ?)", row_order_val, id_val)
      end
    end

    scope.ordered_for_gallery.limit(limit + 1)
  end

  private

  # Fills taken_at/camera/lens from the attached file's EXIF so every creation
  # path (admin form, bulk ingest, rake, API) gets metadata without client JS.
  # Only fills blanks — human input always wins — and only runs when the blob
  # is already in storage (direct upload / io attach). Fail-open via ExifExtractor.
  def fill_metadata_from_exif
    return unless file.attached? && file.blob&.persisted?
    return if taken_at.present? && camera_id.present? && lens_id.present?

    exif = ExifExtractor.from_blob(file.blob)
    self.taken_at ||= exif.taken_at
    self.camera ||= Camera.resolve_from_exif(make: exif.make, model: exif.model)
    self.lens ||= Lens.resolve_from_exif(exif.lens_model)
  end

  def taken_at_is_in_the_past
    return if taken_at.nil?

    errors.add(:taken_at, 'must be in the past') if taken_at > 1.minute.from_now
  end
end
