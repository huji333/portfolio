require 'rails_helper'

RSpec.describe UnattachedBlobsCleanupJob, type: :job do
  def create_blob(created_at:)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
    blob.update!(created_at: created_at)
    blob
  end

  it 'purges unattached blobs older than 24 hours' do
    stale_blob = create_blob(created_at: 25.hours.ago)

    described_class.perform_now

    expect(ActiveStorage::Blob.exists?(stale_blob.id)).to be(false)
  end

  it 'keeps unattached blobs newer than 24 hours' do
    fresh_blob = create_blob(created_at: 1.hour.ago)

    described_class.perform_now

    expect(ActiveStorage::Blob.exists?(fresh_blob.id)).to be(true)
  end

  it 'keeps attached blobs regardless of age' do
    image = create(:image, :draft)
    image.file.blob.update!(created_at: 25.hours.ago)

    described_class.perform_now

    expect(ActiveStorage::Blob.exists?(image.file.blob.id)).to be(true)
  end
end
