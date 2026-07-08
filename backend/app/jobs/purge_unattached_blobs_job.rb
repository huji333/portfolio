# direct upload 後に attach されなかった blob（フォーム離脱・save 失敗の取りこぼし等）を
# 定期回収する安全網。即時 purge（取込失敗時）で拾えないケースをここで拾う。
# config/recurring.yml から日次で起動される。
class PurgeUnattachedBlobsJob < ApplicationJob
  queue_as :default

  # direct upload からフォーム送信までの猶予。これより新しい未 attach blob は
  # 進行中のアップロードの可能性があるため残す。
  RETENTION = 2.days

  def perform
    ActiveStorage::Blob.unattached.where(created_at: ..RETENTION.ago).find_each(&:purge_later)
  end
end
