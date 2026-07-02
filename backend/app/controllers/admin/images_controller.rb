class Admin::ImagesController < Admin::Base
  before_action :set_cameras_and_lenses_and_categories, only: %i[new edit create update]
  before_action :set_image, only: %i[show edit update destroy insert_at]

  def index
    @images = Image.rank(:row_order).with_attached_file
    @uncurated_count = Image.uncurated.count
    @images = @images.uncurated if params[:filter] == "uncurated"
  end

  def show; end

  def new
    @image = Image.new
  end

  def edit; end

  def create
    @image = Image.new(image_params.except(:row_order_position))
    apply_row_order_position(@image)

    if @image.save
      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully created.'
    else
      flash.now[:alert] = 'Image failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    @image.assign_attributes(image_params.except(:row_order_position))
    apply_row_order_position(@image)

    if @image.save
      return redirect_to_next_uncurated if params[:save_and_next].present?

      redirect_to admin_images_path(@image, format: nil), notice: 'Image was successfully updated.'
    else
      flash.now[:alert] = 'Image failed to update.'
      Rails.logger.debug { "Image failed to update: #{@image.errors.full_messages.join(', ')}" }
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
    position = insert_params.to_i
    @image.row_order_position = position
    if @image.save
      head :ok
    else
      render json: { error: @image.errors.full_messages }, status: :unprocessable_content
    end
  end

  # Server-side EXIF resolution for the new/edit form. Takes the signed blob id of
  # an already direct-uploaded file, extracts EXIF with ruby-vips, and find_or_creates
  # the matching Camera/Lens. fail-open: any failure returns nulls so the upload is
  # never blocked.
  def extract_exif
    blob = ActiveStorage::Blob.find_signed!(params[:signed_id])
    exif = ExifExtractor.from_blob(blob)
    camera = Camera.resolve_from_exif(make: exif.make, model: exif.model)
    lens = Lens.resolve_from_exif(exif.lens_model)

    render json: {
      taken_at: exif.taken_at&.in_time_zone&.strftime("%Y-%m-%dT%H:%M"),
      camera: camera && { id: camera.id, label: camera.display_label },
      lens: lens && { id: lens.id, label: lens.name }
    }
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    render json: { taken_at: nil, camera: nil, lens: nil }
  end

  private

  def set_cameras_and_lenses_and_categories
    @cameras = Camera.order(:manufacturer, :name)
    @lenses = Lens.order(:name)
    @categories = Category.order(:name)
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def redirect_to_next_uncurated
    next_image = Image.uncurated.where.not(id: @image.id).rank(:row_order).first
    if next_image
      remaining = Image.uncurated.where.not(id: @image.id).count
      redirect_to edit_admin_image_path(next_image), notice: "保存しました。残り#{remaining}枚の下書きがあります。"
    else
      redirect_to admin_images_path, notice: '保存しました。未編集の下書きはありません。'
    end
  end

  def apply_row_order_position(image)
    image.row_order_position = image_params[:row_order_position].to_i if image_params[:row_order_position].present?
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
