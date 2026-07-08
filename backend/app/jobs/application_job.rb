class ApplicationJob < ActiveJob::Base
  # ジョブ実行前にレコードが削除されていたら何もしない
  discard_on ActiveJob::DeserializationError
end
