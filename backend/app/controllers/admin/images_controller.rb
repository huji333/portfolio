class Admin::ImagesController < Admin::Base
  before_action :set_cameras_and_lenses_and_categories, only: [:new, :edit, :create, :update]
  def index
    @images = Image.all
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def edit
    @image = Image.find(params[:id])
  end

  def create
    categories = Category.where(id: categories_params['category_ids'])
    @image = Image.new(image_params)
    if @image.save
      @image.categories = categories
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
      flash[:alert] = 'Image failed to update.'
      Rails.logger.debug { "Image failed to update.#{@image.errors.full_messages}" }
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image = Image.find(params[:id])
    if @image.destroy
      redirect_to admin_images_path, notice: 'Image was successfully destroyed.'
    else
      redirect_to admin_images_path, alert: 'Image failed to destroy.'
    end
  end

  private

  def set_cameras_and_lenses_and_categories
    @cameras = Camera.all
    @lenses = Lens.all
    @categories = Category.all
  end

  def image_params
    params.require(:image).permit(:title, :caption, :taken_at, :camera_id, :lens_id, :display_order, :is_published, :file)
  end

  def categories_params
    params.require(:image).permit(category_ids: [])
  end
end
