# CdnAttachedFile を include するモデル（Image / Project）の添付ファイル後処理。
# analyze・variant 生成・モデル固有の後処理（after_attached_file_processed）までを
# process_attached_file! が順序込みで担う（順序保証の詳細は concern 側に集約）。
class ProcessAttachedFileJob < ApplicationJob
  queue_as :default

  # S3 / ネットワークの一過性エラー（可用性低下・スロットリング・タイムアウト）。
  # vips のデコード失敗など恒久的なエラーはここに含めない（fail-loud のまま）。
  TRANSIENT_ERRORS = [
    Aws::S3::Errors::ServiceUnavailable,
    Aws::S3::Errors::InternalError,
    Aws::S3::Errors::SlowDown,
    Seahorse::Client::NetworkingError,
    Errno::ECONNRESET,
    Net::OpenTimeout,
    Net::ReadTimeout
  ].freeze

  # io attach（rake/runner/フォーム）では after_commit のエンキューが S3 アップロード
  # 完了より先に走りうる（callback 定義順の race）。transient なので有限リトライし、
  # 使い切ったら fail-loud（failed executions に残る）。
  retry_on ActiveStorage::FileNotFoundError, wait: :polynomially_longer, attempts: 5
  retry_on(*TRANSIENT_ERRORS, wait: :polynomially_longer, attempts: 5)

  def perform(record)
    record.process_attached_file!
  end
end
