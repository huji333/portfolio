require 'rails_helper'

RSpec.describe ProcessAttachedFileJob, type: :job do
  include ActiveJob::TestHelper

  describe 'enqueue wiring (CdnAttachedFile)' do
    it 'enqueues on image create' do
      expect { create(:image) }.to have_enqueued_job(described_class)
    end

    it 'does not re-enqueue on save once the file is processed' do
      image = create(:image)
      perform_enqueued_jobs

      expect { image.reload.update!(title: 'renamed') }.not_to have_enqueued_job(described_class)
    end
  end

  describe '#perform' do
    it 'analyzes the file, generates variants, and fills EXIF metadata' do
      image = create(:image, :draft)
      perform_enqueued_jobs

      image.reload
      expect(image.file).to be_analyzed
      expect(image.file.metadata).to include('width', 'height')
      expect(image.thumbnail_variant.image).to be_attached
      expect(image.camera).to have_attributes(make: 'SONY', model: 'ILCE-7CM2')
      expect(image.taken_at).to be_present
    end

    it 'processes records without EXIF support (Project)' do
      project = build(:project)
      project.file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/test_image.jpg'), 'image/jpeg'
      )
      project.save!
      perform_enqueued_jobs

      expect(project.reload.file).to be_analyzed
    end

    # io attach 経路ではエンキューが S3 アップロード完了より先に走りうる（race）ため
    # FileNotFoundError はリトライする。上限到達後の再 raise（fail-loud → failed
    # executions に残る）は retry_on の framework 保証なのでここでは検証しない。
    it 'retries when the blob is not yet in storage' do
      image = create(:image)
      allow(image).to receive(:process_attached_file!).and_raise(ActiveStorage::FileNotFoundError)
      clear_enqueued_jobs

      expect { described_class.perform_now(image) }.to have_enqueued_job(described_class)
    end
  end
end
