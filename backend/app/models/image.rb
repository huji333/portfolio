class Image < ApplicationRecord
  include RankedModel
  ranks :row_order

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

  after_commit :analyze_attached_file, on: %i[create update]

  # 画像のURLを提供
  def file_url
    return nil unless file.attached?

    file.blob.url(expires_in: 1.hour, disposition: "inline", filename: file.filename)
  rescue StandardError => e
    Rails.logger.error "file_url error (image #{id}): #{e.full_message}"
    nil
  end

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

  def analyze_attached_file
    return unless file.attached?
    return if file.analyzed?

    file.analyze
  end
end
