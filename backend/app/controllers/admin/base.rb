class Admin::Base < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def render404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  rescue_from ActiveRecord::RecordNotFound do
    render404
  end

  private

  def check_admin
    return if current_user&.role_admin?

    message = 'You are not authorized to perform this action.'
    respond_to do |format|
      format.html { render plain: message, status: :unauthorized }
      format.json { render json: { error: message }, status: :unauthorized }
      format.any  { head :unauthorized }
    end
  end
end
