require 'rails_helper'

RSpec.describe ProcessAttachedFileJob, type: :job do
  include ActiveJob::TestHelper

  describe 'enqueue wiring (CdnAttachedFile)' do
    it 'enqueues on image create' do
      expect { create(:image) }.to have_enqueued_job(described_class)
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
    # analyze・variant×2・EXIF の計4回 + 標準 AnalyzeJob の1回をダウンロードしていた
    # 経路の回帰テスト（#276）。storage service への download 呼び出し回数で
    # S3 GET を計測する（enqueue された全ジョブを流して取込1件分の合計を見る）。
    # そのため標準 ActiveStorage::AnalyzeJob が抑止されず動いてしまえば回数が
    # 増えて落ちる。AnalyzeJob 抑止（#276）自体の直接テストはこれで兼ねる。
    it 'downloads the original blob from storage only once per ingest (regression: #276)' do
      image = create(:image, :draft)
      service = ActiveStorage::Blob.service
      allow(service).to receive(:download).and_call_original

      perform_enqueued_jobs

      image.reload
      expect(service).to have_received(:download).with(image.file.blob.key).once
      # ダウンロード共有後も全工程が成立していること（analyze / variant / EXIF）
      expect(image.file).to be_analyzed
      expect(image.thumbnail_variant.image).to be_attached
      expect(image.camera).to be_present
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
  end

  describe 'retry_on behavior' do
    # io attach 経路ではエンキューが S3 アップロード完了より先に走りうる（race）ため
    # FileNotFoundError はリトライする。上限到達後の再 raise（fail-loud → failed
    # executions に残る）は retry_on の framework 保証なのでここでは検証しない。
    it 'retries when the blob is not yet in storage' do
      image = create(:image)
      allow(image).to receive(:process_attached_file!).and_raise(ActiveStorage::FileNotFoundError)
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
