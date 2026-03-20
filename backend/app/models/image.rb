class Image < ApplicationRecord
  include RankedModel
  include CdnAttachedFile

  ranks :row_order
  THUMBNAIL_LIMIT = [960, 960].freeze

  has_many :image_categories, dependent: :destroy
  has_many :categories, through: :image_categories
  belongs_to :camera
  belongs_to :lens

  has_one_attached :file, dependent: :purge_later

  validates :file, presence: true
  validates :title, presence: true
  validates :caption, presence: true
  validates :taken_at, presence: true
  validates :is_published, inclusion: { in: [true, false] }

  scope :published, -> { where(is_published: true) }
  scope :ordered_for_gallery, -> { order(row_order: :asc, id: :asc) }

  validate :taken_at_is_in_the_past

  def category_ids=(ids)
    super
    # 保存後にカテゴリーの関連付けを更新
    return unless persisted?

    self.categories = Category.where(id: ids.compact_blank)
  end

  def self.filter_by_categories(category_ids)
    return all if category_ids.blank?

    where(id: ImageCategory.where(category_id: category_ids).select(:image_id))
  end

  def self.for_gallery(category_ids: nil, cursor: nil, limit: 20)
    scope = published
            .filter_by_categories(category_ids)
            .with_attached_file
            .includes(:camera, :lens, :categories)

    if cursor.present?
      row_order_val, id_val = cursor.split(",").map(&:to_i)
      scope = scope.where(
        "(row_order, id) > (?, ?)", row_order_val, id_val
      )
    end

    scope.ordered_for_gallery.limit(limit + 1)
  end

  private

  def taken_at_is_in_the_past
    return if taken_at.nil?

    errors.add(:taken_at, 'must be in the past') if taken_at > Time.zone.now
  end
end
