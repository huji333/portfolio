class Image < ApplicationRecord
  include RankedModel
  ranks :row_order

  has_many :image_categories, dependent: :destroy
  has_many :categories, through: :image_categories
  belongs_to :camera
  belongs_to :lens

  has_one_attached :file

  validates :file, presence: true
  validates :title, presence: true
  validates :caption, presence: true
  validates :taken_at, presence: true
  validates :is_published, inclusion: { in: [true, false] }

  scope :published, -> { where(is_published: true) }

  # 画像のURLを提供
  def file_url
    return nil unless file.attached?

    # ActiveStorage::Current.url_optionsが設定されていれば、適切なURLが生成される
    # S3の場合は署名付きURL、Diskの場合はローカルURL
    if Rails.env.production?
      # 本番環境では署名付きURLを使用（セキュリティのため）
      file.service_url(expires_in: 1.hour)
    else
      # 開発環境では通常のURLを使用
      file.url
    end
  rescue => e
    Rails.logger.error "Failed to generate URL for image #{id}: #{e.message}"
    nil
  end

  validate :taken_at_is_in_the_past

  # リサイズ後にメタデータを更新(縦横のピクセル数など)
  after_create_commit :analyze_image

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

  def analyze_image
    return unless file.attached?

    file.analyze
  end
end
