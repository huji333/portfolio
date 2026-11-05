# ログインの試行回数を IP ごとに制限し、admin アカウントへの総当たりを防ぐ。
class Users::SessionsController < Devise::SessionsController
  # Rails.cache は dev/test で NullStore、本番も未設定のため、レート制限を cache の
  # 設定に左右させないよう専用の MemoryStore を使う。puma は 1 worker
  # （config/puma.rb の WEB_CONCURRENCY 既定 1）なので、プロセス内の store で足りる。
  # worker を増やすときは共有 store（Solid Cache 等）に移すこと。
  RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new
  MAX_LOGIN_ATTEMPTS = 10

  rate_limit to: MAX_LOGIN_ATTEMPTS, within: 3.minutes, only: :create, store: RATE_LIMIT_STORE
end
