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
    make = params[:make]&.strip
    model = params[:model]&.strip

    if make.present? && model.present?
      # メーカー名とモデル名で検索（部分一致）
      camera = Camera.where("LOWER(manufacturer) LIKE ? AND LOWER(name) LIKE ?",
                            "%#{make.downcase}%", "%#{model.downcase}%").first

      if camera
        render json: { id: camera.id, name: camera.name, manufacturer: camera.manufacturer }
      else
        render json: { error: 'Camera not found' }, status: :not_found
      end
    else
      render json: { error: 'Make and model parameters are required' }, status: :bad_request
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
