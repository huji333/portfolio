class Image < ApplicationRecord
  include CdnAttachedFile
  include ImageGalleryOrdering

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

  validate :taken_at_is_in_the_past

  def category_ids=(ids)
    super(Array(ids).compact_blank)
  end

  def publishable?
    PUBLISH_REQUIREMENTS.all? { |attr| public_send(attr).present? }
  end

  # variant 生成後に CdnAttachedFile#process_attached_file! から呼ばれる後処理フック。
  # EXIF 抽出は S3 フルダウンロードを伴うためリクエスト内では行わずここ（ジョブ内）で実行する。
  def after_attached_file_processed
    fill_exif_metadata!
  end

  # EXIF 補完（旧: before_validation on: :create）。フック経由のほか spec からも直接叩く。
  def fill_exif_metadata!
    fill_metadata_from_exif
    save! if changed?
  end

  # 一括メタデータ付与。nil の属性は変更せず、カテゴリは既存への追加（union）。
  # 部分成功を作らない：ID の欠落や 1 件の失敗で全体をロールバックする（fail-loud）。
  def self.bulk_assign!(ids, camera: nil, lens: nil, categories: [])
    images = where(id: ids).to_a
    raise ActiveRecord::RecordNotFound, 'Some images not found' if images.size != ids.uniq.size

    transaction do
      images.each do |image|
        image.update!({ camera: camera, lens: lens }.compact)
        categories.each { |category| image.image_categories.find_or_create_by!(category: category) }
      end
    end
    images
  end

  def self.filter_by_categories(category_ids)
    return all if category_ids.blank?

    where(id: ImageCategory.where(category_id: category_ids).select(:image_id))
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
