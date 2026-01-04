class Project < ApplicationRecord
  include CdnAttachedFile

  THUMBNAIL_LIMIT = [1440, 1440].freeze

  has_one_attached :file, dependent: :purge_later

  validates :title, presence: true
  validates :link, presence: true
end
