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

    # 処理待ちのままでも、添付が変わらない update（キュレーション編集）で
    # 重複ジョブを積まない（#277）。
    it 'does not enqueue a duplicate job on a file-unchanged update while still unprocessed' do
      image = create(:image)
      clear_enqueued_jobs

      expect { image.reload.update!(title: 'renamed') }.not_to have_enqueued_job(described_class)
    end

    it 'does not look up variant records on a file-unchanged update (regression: #277)' do
      image = create(:image)
      perform_enqueued_jobs
      reloaded = Image.find(image.id)

      queries = sql_queries_matching(/active_storage_variant_records/) do
        reloaded.update!(title: 'renamed')
      end

      expect(queries).to be_empty
    end

    it 'enqueues again when the file itself is replaced' do
      image = create(:image)
      perform_enqueued_jobs
      clear_enqueued_jobs

      expect do
        image.reload.file.attach(
          io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
          filename: 'replaced.jpg', content_type: 'image/jpeg'
        )
      end.to have_enqueued_job(described_class)
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

  describe 'TRANSIENT_ERRORS retry configuration' do
    it 'covers the expected S3 / network transient error classes' do
      expect(described_class::TRANSIENT_ERRORS).to contain_exactly(
        Aws::S3::Errors::ServiceUnavailable,
        Aws::S3::Errors::InternalError,
        Aws::S3::Errors::SlowDown,
        Seahorse::Client::NetworkingError,
        Errno::ECONNRESET,
        Net::OpenTimeout,
        Net::ReadTimeout
      )
    end

    # TRANSIENT_ERRORS の一部（Errno::ECONNRESET）で実際に retry_on が起動することを
    # 確認する代表ケース。上限到達後の再 raise は framework 保証なのでここでは検証しない。
    it 'retries on a transient S3/network error (e.g. Errno::ECONNRESET)' do
      image = create(:image)
      allow(image).to receive(:process_attached_file!).and_raise(Errno::ECONNRESET)
      clear_enqueued_jobs

      expect { described_class.perform_now(image) }.to have_enqueued_job(described_class)
    end

    # 破損画像の vips デコード失敗など恒久的なエラーは retry_on の対象外のまま
    # （fail-loud → failed executions に残る）ことを確認する。
    it 'does not retry a non-transient StandardError and lets it propagate' do
      image = create(:image)
      allow(image).to receive(:process_attached_file!).and_raise(StandardError, 'corrupt image')
      clear_enqueued_jobs

      expect { described_class.perform_now(image) }.to raise_error(StandardError, 'corrupt image')
      expect(enqueued_jobs).to be_empty
    end
  end
end
