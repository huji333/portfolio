class Admin::ImagesController < Admin::Base
  def index
    @images = Image.all
  end

  def show
    @image = Image.find(params[:id])
    render json: @image
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      render json: @image, status: :created, location: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def update
    @image = Image.find(params[:id])
    if @image.update(image_params)
      render json: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
  end

  private

  def image_params
    params.require(:image).permit(:title, :caption, :taken_at, :camera_id, :lens_id, :display_order, :is_published, :file)
  end
end
