class Admin::ImagesController < Admin::Base
  def index
    @images = Image.all
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
    @cameras = Camera.all
    @lenses = Lens.all
    @categories = Category.all
  end

  def edit
    @image = Image.find(params[:id])
    @cameras = Camera.all
    @lenses = Lens.all
    @categories = Category.all
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully created.'
    else
      flash.now[:alert] = 'Image faild to create.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @image = Image.find(params[:id])
    if @image.update(image_params)
      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully updated.'
    else
      flash[:alert] = 'Image faild to update.'
      Rails.logger.debug "Image faild to update.#{@image.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image = Image.find(params[:id])
    if @image.destroy
      redirect_to admin_images_path, notice: 'Image was successfully destroyed.'
    else
      redirect_to admin_images_path, alert: 'Image faild to destroy.'
    end
  end

  private

  def image_params
    params.require(:image).permit(:title, :caption, :taken_at, :camera_id, :lens_id, :display_order, :is_published, :file, category_ids: [])
  end
end
