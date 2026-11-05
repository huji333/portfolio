# ログインとパスワード再設定メールの送信回数を IP ごとに制限する。
# admin アカウントへの総当たりと、再設定メールの連打を防ぐ。
#
# Rails.cache は dev/test で NullStore、本番も未設定のため、レート制限を cache の
# 設定に左右させないよう専用の MemoryStore を使う。puma は 1 worker
# （config/puma.rb の WEB_CONCURRENCY 既定 1）なので、プロセス内の store で足りる。
# worker を増やすときは共有 store（Solid Cache 等）に移すこと。
module AuthRateLimit
  extend ActiveSupport::Concern

  STORE = ActiveSupport::Cache::MemoryStore.new
  MAX_ATTEMPTS = 10
  WINDOW = 3.minutes

  class_methods do
    def limit_auth_attempts(only:)
      rate_limit to: MAX_ATTEMPTS, within: WINDOW, only:, store: STORE
    end
  end
end
