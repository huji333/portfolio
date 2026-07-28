class Project < ApplicationRecord
  include CdnAttachedFile

  THUMBNAIL_LIMIT = [1440, 1440].freeze
  DISPLAY_LIMIT = [1920, 1920].freeze

  has_one_attached :file, dependent: :purge_later

  validates :title, presence: true
  validates :link, presence: true, format: { with: %r{\Ahttps?://[^\s]+\z}, message: "は正しいURLの形式で入力してください (http:// または https:// で始まる必要があります)" }

  # Admin form submits tags as a comma-separated string.
  def tags=(value)
    value = value.split(",").map(&:strip).reject(&:empty?).uniq if value.is_a?(String)
    super(value || [])
  end
end
