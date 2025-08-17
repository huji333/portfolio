class Admin::CamerasController < Admin::Base
  before_action :set_camera, only: [:show, :edit, :update, :destroy]

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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @camera.update(camera_params)
      redirect_to admin_cameras_path, notice: 'Camera was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @camera.destroy
    redirect_to admin_cameras_path, notice: 'Camera was successfully destroyed.'
  end

  def lookup
    camera_name = params[:camera_name]&.strip
    manufacturer = params[:manufacturer]&.strip

    if camera_name.present? || manufacturer.present?
      # カメラ名とメーカー名で検索
      camera = Camera.lookup(camera_name, manufacturer)

      if camera
        render json: { id: camera.id, name: camera.name, manufacturer: camera.manufacturer }
      else
        render json: { error: 'Camera not found' }, status: :not_found
      end
    else
      render json: { error: 'Camera name or manufacturer parameter is required' }, status: :bad_request
    end
  end

  private

  def set_camera
    @camera = Camera.find(params[:id])
  end

  def camera_params
    params.require(:camera).permit(:name, :manufacturer)
  end
end
