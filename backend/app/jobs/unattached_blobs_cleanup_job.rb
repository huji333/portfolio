# 一括取込での重複検出・保存失敗時は purge_later で都度後始末するが、プロセス異常終了
# 等で漏れた孤立 blob（direct upload は S3 アップロード前に blob 行ができるため発生しうる）
# の保険。24時間より古い未 attach blob だけを対象にし、アップロード中の新しい blob は
# 消さない。config/recurring.yml から日次で起動。
# purge は例外を rescue しない（fail-loud）：失敗は Solid Queue の failed executions に残る。
class UnattachedBlobsCleanupJob < ApplicationJob
  queue_as :default

  STALE_AFTER = 24.hours

  def perform
    ActiveStorage::Blob.unattached.where(created_at: ...STALE_AFTER.ago).find_each(&:purge)
  end
end
