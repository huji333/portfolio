class Project < ApplicationRecord
  has_one_attached :file, dependent: :purge_later

  validates :title, presence: true
  validates :link, presence: true

  def file_url
    return nil unless file.attached?

    file.blob.url(expires_in: 1.hour, disposition: "inline", filename: file.filename)
  rescue StandardError => e
    Rails.logger.error "file_url error (project #{id}): #{e.full_message}"
    nil
  end
end
