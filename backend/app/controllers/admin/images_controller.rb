class Admin::ImagesController < Admin::Base
  include Admin::ImageCurationFlow
  include Admin::ClampedPagination

  PER_PAGE = 50

  before_action :set_cameras_and_lenses_and_categories, only: %i[index new edit create update]
  before_action :set_image, only: %i[show edit update destroy insert_at]
  before_action :set_adjacent_images, only: %i[edit update]

  def index
    scope = Image.order(:id).with_attached_file
    scope = scope.uncurated if params[:filter] == "uncurated"
    @uncurated_count = Image.uncurated.count
    @pagy, @images = pagy_clamped(scope, limit: PER_PAGE)
  end

  # 並び替え専用画面。featured のみを表示する（ギャラリー先頭に pin される集合）。
  def arrange
    @images = Image.featured.with_attached_file
  end

  def show; end

  def new
    @image = Image.new
  end

  def edit; end

  def create
    @image = Image.new(image_params.except(:is_featured))
    @image.is_published = publish_intent || false

    if @image.save
      apply_featured_toggle
      redirect_to admin_images_path, notice: update_notice
    else
      flash.now[:alert] = 'Image failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    @image.assign_attributes(image_params.except(:is_featured))
    intent = publish_intent
    @image.is_published = intent unless intent.nil?

    if @image.save
      apply_featured_toggle
      redirect_to after_save_edit_path, notice: update_notice
    else
      # 公開しようとして弾かれた場合もフォームは元の公開状態のまま再描画する
      @image.restore_attributes(%i[is_published])
      flash.now[:alert] = 'Image failed to update.'
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

  # 並び替え画面は featured のみを表示するため、ドロップ位置＝featured リスト内 index
  # ＝そのまま featured_rank。現在の featured 順から対象画像を抜いて挿入位置へ差し込み、
  # 全体を 0..N-1 へ正規化する。
  def insert_at
    ids = Image.featured.where.not(id: @image.id).pluck(:id)
    ids.insert(insert_params.to_i.clamp(0, ids.size), @image.id)
    Image.reorder_featured!(ids)
    head :ok
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  # Server-side EXIF resolution for the new/edit form. Fail-open: any failure returns
  # nulls so the upload is never blocked.
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
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound,
         ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
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

  # image_params[:is_featured] はチェックボックス経由の仮想属性（featured_rank は
  # 保存後に Image#feature!/#unfeature! 経由で正規化する）。未送信（新規作成フォーム
  # 以外での省略等）は変更なしとして扱う。
  def apply_featured_toggle
    return if image_params[:is_featured].nil?

    wants_featured = ActiveModel::Type::Boolean.new.cast(image_params[:is_featured])
    if wants_featured
      @image.feature!
    else
      @image.unfeature!
    end
  end

  def image_params
    params.expect(
      image: [:title, :caption, :taken_at, :camera_id, :lens_id,
              :is_featured, :file,
              { category_ids: [] }]
    )
  end

  def insert_params
    params.require(:position)
  end
end
