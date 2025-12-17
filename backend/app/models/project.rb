class Project < ApplicationRecord
  has_one_attached :file, dependent: :purge_later

  validates :title, presence: true
  validates :link, presence: true

  after_commit :analyze_attached_file, on: %i[create update]

  def file_url
    return nil unless file.attached?

    file.blob.url(expires_in: 1.hour, disposition: "inline", filename: file.filename)
  rescue StandardError => e
    Rails.logger.error "file_url error (project #{id}): #{e.full_message}"
    nil
  end

  private

  def analyze_attached_file
    return unless file.attached?
    return if file.analyzed?

    file.analyze
  end
end
