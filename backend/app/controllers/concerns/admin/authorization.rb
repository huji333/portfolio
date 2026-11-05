# admin ロールのログインユーザーだけを通す。Admin::Base と、Admin::Base を
# 継承できない Active Storage の上書きコントローラ（Admin::DirectUploadsController）
# で同じ判定を使う。
module Admin::Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :check_admin
  end

  private

  def check_admin
    return if current_user&.role_admin?

    message = 'You are not authorized to perform this action.'
    respond_to do |format|
      format.html { render plain: message, status: :forbidden }
      format.json { render json: { error: message }, status: :forbidden }
      format.any  { head :forbidden }
    end
  end
end
