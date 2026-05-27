class Api::CameraNamesController < ApplicationController
  skip_before_action :verify_authenticity_token # 管理画面の Stimulus コントローラから fetch で呼び出すため
  before_action :authenticate_user!

  def create
    make  = params[:make]&.strip
    model = params[:model]&.strip

    if make.blank? || model.blank?
      render json: { error: 'make and model parameters are required' }, status: :bad_request
      return
    end

    resolved_name = CameraName.resolve(make, model)

    render json: {
      manufacturer: make,
      camera_name: resolved_name
    }
  end
end
