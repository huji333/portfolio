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

  validate :taken_at_is_in_the_past

  def category_ids=(ids)
    super
    # 保存後にカテゴリーの関連付けを更新
    return unless persisted?

    self.categories = Category.where(id: ids.compact_blank)
  end

  def self.filter_by_categories(category_ids)
    return all if category_ids.blank?

    joins(:categories)
      .where(categories: { id: category_ids })
      .distinct
  end

  private

  def taken_at_is_in_the_past
    return if taken_at.nil?

    errors.add(:taken_at, 'must be in the past') if taken_at > Time.zone.now
  end
end
