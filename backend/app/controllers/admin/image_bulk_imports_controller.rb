class Admin::ImageBulkImportsController < Admin::Base
  before_action :set_form_options

  def new
    @results = nil
  end

  # Ingests each direct-uploaded blob as a draft Image (EXIF metadata is filled
  # by the model layer). Failures are isolated per file so one bad frame never
  # aborts the rest of the roll; the result list says exactly which files failed.
  def create
    signed_ids = Array(params.dig(:bulk, :files)).compact_blank

    if signed_ids.empty?
      flash.now[:alert] = 'ファイルが選択されていません。'
      return render :new, status: :unprocessable_content
    end

    @results = signed_ids.map { |signed_id| ingest_draft(signed_id, shared_attributes) }
    failed = @results.count { |result| result[:image].nil? || !result[:image].persisted? }

    if failed.zero?
      redirect_to admin_images_path(filter: "uncurated"),
                  notice: "#{@results.size}枚を下書きとして取り込みました。1枚ずつタイトルを付けて公開してください。"
    else
      flash.now[:alert] = "#{failed}枚の取り込みに失敗しました（#{@results.size - failed}枚は成功）。"
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_form_options
    @categories = Category.order(:name)
    @cameras = Camera.order(:manufacturer, :name)
    @lenses = Lens.order(:name)
  end

  # 全画像に共通で付ける属性。camera/lens は明示指定があれば EXIF より優先される
  # （モデルの fill_metadata_from_exif は空欄しか埋めないため、渡すだけで成立する）。
  def shared_attributes
    {
      category_ids: Array(params.dig(:bulk, :category_ids)).compact_blank,
      camera_id: params.dig(:bulk, :camera_id).presence,
      lens_id: params.dig(:bulk, :lens_id).presence
    }.compact
  end

  def ingest_draft(signed_id, shared_attributes)
    blob = ActiveStorage::Blob.find_signed!(signed_id)
    image = Image.new(file: signed_id, is_published: false, **shared_attributes)
    image.save
    { filename: blob.filename.to_s, image: image, errors: image.errors.full_messages }
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    { filename: signed_id.to_s.truncate(24), image: nil, errors: ['アップロードが無効です（再アップロードしてください）'] }
  end
end
