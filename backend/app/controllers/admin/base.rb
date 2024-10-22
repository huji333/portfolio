class Admin::Base < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  private

  def check_admin
    unless current_user.role_admin?
      render json: { error: 'You are not authorized to perform this action.' }, status: :unauthorized
    end
  end
end