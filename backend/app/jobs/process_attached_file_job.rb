# CdnAttachedFile を include するモデル（Image / Project）の添付ファイル後処理。
# analyze と variant 生成を先に済ませてから EXIF 補完の save を行う——この順序で
# save 時の after_commit 再エンキュー判定（attached_file_needs_processing?）が
# false になり、ジョブの連鎖が止まる。
class ProcessAttachedFileJob < ApplicationJob
  queue_as :default

  # io attach（rake/runner/フォーム）では after_commit のエンキューが S3 アップロード
  # 完了より先に走りうる（callback 定義順の race）。transient なので有限リトライし、
  # 使い切ったら fail-loud（failed executions に残る）。
  # NoSuchKey も対象: S3Service#stream はチャンク GET 途中の NoSuchKey を
  # FileNotFoundError に包まず生のまま上げる（初回 GET しか wrap されない）。
  retry_on ActiveStorage::FileNotFoundError, Aws::S3::Errors::NoSuchKey,
           wait: :polynomially_longer, attempts: 5

  def perform(record)
    record.process_attached_file!
    record.fill_exif_metadata! if record.respond_to?(:fill_exif_metadata!)
  end
end
