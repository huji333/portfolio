# Active Storage 既定の direct upload（POST /rails/active_storage/direct_uploads）は
# 認証なしで blob と S3 の署名付きアップロード URL を発行する。admin のフォームしか
# 使わないため、同じパスをこのコントローラで先に受けて admin 以外を拒否する。
# ルートは config/routes.rb を参照（アプリのルートは Active Storage のルートより先に照合される）。
class Admin::DirectUploadsController < ActiveStorage::DirectUploadsController
  include Admin::Authorization
end
