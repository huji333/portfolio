class Admin::CamerasController < Admin::Base
  def index
    @cameras = Camera.all
  end
  def create
    @camera = Camera.new(camera_params)
    if @camera.save
      redirect_to admin_cameras_path, notice: 'Camera was successfully created.'
    end
  end
  def new
    @camera = Camera.new
  end
  def edit
    @camera = Camera.find(params[:id])
  end
  def destroy
    @camera = Camera.find(params[:id])
    if @camera.destroy
      redirect_to admin_cameras_path, notice: 'Camera was successfully destroyed.'
    else
      redirect_to admin_cameras_path, alert: 'Camera failed to destroy.'
    end
  end

  private

  def camera_params
    params.require(:camera).permit(:name, :manufacturer)
  end
end
