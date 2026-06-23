class Admin::CamerasController < Admin::Base
  before_action :set_camera, only: %i[show edit update destroy]

  def index
    @cameras = Camera.all
  end

  def show; end

  def new
    @camera = Camera.new
  end

  def edit; end

  def create
    @camera = Camera.new(camera_params)

    if @camera.save
      redirect_to admin_cameras_path, notice: 'Camera was successfully created.'
    else
      flash.now[:alert] = 'Camera failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @camera.update(camera_params)
      redirect_to admin_cameras_path, notice: 'Camera was successfully updated.'
    else
      flash.now[:alert] = 'Camera failed to update.'
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @camera.destroy
      redirect_to admin_cameras_path, notice: 'Camera was successfully destroyed.'
    else
      redirect_to admin_cameras_path, alert: 'Camera could not be destroyed.'
    end
  end

  private

  def set_camera
    @camera = Camera.find(params[:id])
  end

  def camera_params
    params.expect(camera: %i[name manufacturer])
  end
end
