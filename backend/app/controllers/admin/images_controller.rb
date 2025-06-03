class Admin::ImagesController < Admin::Base
  before_action :set_cameras_and_lenses_and_categories, only: [:new, :edit, :create, :update]
  before_action :set_image, only: [:show, :edit, :update, :destroy, :insert_at]

  def index
    @images = Image.rank(:row_order).all
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
    @image = Image.new(image_params.except(:file, :position))
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
      # positionパラメータがある場合は、指定位置に挿入
      if image_params[:position].present?
        position = image_params[:position].to_i
        total_count = Image.count
        insert_position = [position, total_count].min
        @image.row_order_position = insert_position
      end
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

  def insert_at
    position = insert_params.to_i # require(:position)は直接値を返すので、[:position]は不要
    @image.row_order_position = position
    if @image.save
      head :ok
    else
      render json: { error: @image.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_cameras_and_lenses_and_categories
    @cameras = Camera.all
    @lenses = Lens.all
    @categories = Category.all
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(
      :title, :caption, :taken_at, :camera_id, :lens_id,
      :row_order, :is_published, :file, :position,
      category_ids: []
    )
  end

  def insert_params
    params.require(:position)
  end
end
