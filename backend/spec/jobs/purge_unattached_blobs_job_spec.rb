require 'rails_helper'

RSpec.describe PurgeUnattachedBlobsJob, type: :job do
  include ActiveJob::TestHelper

  def create_blob
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
      filename: 'test_image.jpg', content_type: 'image/jpeg'
    )
  end

  it 'purges unattached blobs older than the retention period' do
    stale = create_blob
    stale.update!(created_at: (described_class::RETENTION + 1.hour).ago)

    described_class.perform_now
    perform_enqueued_jobs

    expect(ActiveStorage::Blob.exists?(stale.id)).to be(false)
  end

  it 'keeps recent unattached blobs (upload may be in progress)' do
    fresh = create_blob

    described_class.perform_now
    perform_enqueued_jobs

    expect(ActiveStorage::Blob.exists?(fresh.id)).to be(true)
  end

  it 'keeps attached blobs regardless of age' do
    image = create(:image)
    image.file.blob.update!(created_at: (described_class::RETENTION + 1.hour).ago)

    described_class.perform_now
    perform_enqueued_jobs

    expect(ActiveStorage::Blob.exists?(image.file.blob.id)).to be(true)
  end
end
