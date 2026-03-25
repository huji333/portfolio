class Project < ApplicationRecord
  include CdnAttachedFile

  THUMBNAIL_LIMIT = [1440, 1440].freeze

  has_one_attached :file, dependent: :purge_later

  validates :title, presence: true
  validates :link, presence: true, format: { with: %r{\Ahttps?://.+\z}, message: "は正しいURLの形式で入力してください (http:// または https:// で始まる必要があります)" }
end
