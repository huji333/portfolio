class Admin::ImagesController < Admin::Base
  before_action :set_cameras_and_lenses_and_categories, only: %i[new edit create update]
  before_action :set_image, only: %i[show edit update destroy insert_at]

  def index
    @images = Image.rank(:row_order).all
  end

  def show; end

  def new
    @image = Image.new
  end

  def edit; end

  def create
    @image = Image.new(image_params.except(:row_order_position))
    @image.row_order_position = image_params[:row_order_position].to_i if image_params[:row_order_position].present?

    if @image.save
      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully created.'
    else
      flash.now[:alert] = 'Image failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    params_hash = image_params.except(:row_order_position)

    if @image.update(params_hash)
      # row_order_positionが指定されている場合は順序を更新
      if image_params[:row_order_position].present?
        position = image_params[:row_order_position].to_i
        @image.row_order_position = position
        @image.save
      end
      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully updated.'
    else
      flash[:alert] = 'Image failed to update.'
      Rails.logger.debug { "Image failed to update.#{@image.errors.full_messages}" }
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
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
      render json: { error: @image.errors.full_messages }, status: :unprocessable_content
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
    params.expect(
      image: [:title, :caption, :taken_at, :camera_id, :lens_id,
              :row_order_position, :is_published, :file,
              { category_ids: [] }]
    )
  end

  def insert_params
    params.require(:position)
  end
end
