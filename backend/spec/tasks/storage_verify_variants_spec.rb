require 'rails_helper'
require 'rake'

# 2026-06-18 インシデントの再現: S3 アップロード失敗で VariantRecord/blob 行は残るが
# 実体（S3 オブジェクト）が無い状態を、test storage（Disk）上でファイルを直接消して模す。
RSpec.describe 'storage:verify_variants rake task' do
  include ActiveJob::TestHelper

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('storage:verify_variants')
  end

  let(:task) { Rake::Task['storage:verify_variants'] }

  after { task.reenable }

  around do |example|
    original_fix = ENV.delete('FIX')
    example.run
    ENV['FIX'] = original_fix
  end

  def orphan_thumbnail_variant_record!(image)
    perform_enqueued_jobs

    # variant.variation.digest で実際に使われた digest を引く（resize_to_limit 以外にも
    # processor 由来のデフォルトオプションが乗るため、手計算の digest とは一致しない）。
    digest = image.thumbnail_variant.variation.digest
    variant_record = ActiveStorage::VariantRecord.find_by!(blob_id: image.file.blob.id, variation_digest: digest)

    blob = variant_record.image.blob
    blob.service.delete(blob.key) # DB 上は generated 済みに見えるが実体が無い状態を再現する

    variant_record
  end

  it 'detects a variant missing on S3 and fails loudly (non-zero exit) without FIX' do
    image = create(:image)
    variant_record = orphan_thumbnail_variant_record!(image)

    expect { task.invoke }.to raise_error(SystemExit) { |error| expect(error.status).not_to eq(0) }
    expect(ActiveStorage::VariantRecord.exists?(variant_record.id)).to be true
  end

  it 'repairs the missing variant when FIX=1' do
    ENV['FIX'] = '1'
    image = create(:image)
    variant_record = orphan_thumbnail_variant_record!(image)

    expect { task.invoke }.not_to raise_error
    expect(ActiveStorage::VariantRecord.exists?(variant_record.id)).to be false

    perform_enqueued_jobs
    image.reload

    expect(image.thumbnail_variant.image).to be_attached
    expect(image.thumbnail_variant.service.exist?(image.thumbnail_variant.key)).to be true
  end
end
