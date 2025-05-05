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
    @image = Image.new(image_params.except(:file))
    @image.category_ids = image_params[:category_ids] if image_params[:category_ids].present?
    # 長辺が1920px以内になるようにリサイズしたものを添付
    if (uploaded = image_params[:file]).present?
      processed_io = Image.resize_io(uploaded.tempfile)
      processed_io.rewind # 念のため先頭へ

      @image.file.attach(
        io: processed_io,
        filename: "#{uploaded.original_filename}_1920.jpg",
        content_type: 'image/jpeg'
      )
    end

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
    params.require(:image).permit(
      :title, :caption, :taken_at, :camera_id, :lens_id,
      :display_order, :is_published, :file,
      category_ids: []
    )
  end
end
