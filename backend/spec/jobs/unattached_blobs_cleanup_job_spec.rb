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

  it 'purges only stale unattached blobs, keeping fresh and attached ones' do
    stale_blob = create_blob(created_at: 25.hours.ago)
    fresh_blob = create_blob(created_at: 1.hour.ago)
    image = create(:image, :draft)
    image.file.blob.update!(created_at: 25.hours.ago)

    described_class.perform_now

    expect(ActiveStorage::Blob.exists?(stale_blob.id)).to be(false)
    expect(ActiveStorage::Blob.exists?(fresh_blob.id)).to be(true)
    expect(ActiveStorage::Blob.exists?(image.file.blob.id)).to be(true)
  end
end
