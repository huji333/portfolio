class Admin::ImageBulkImportsController < Admin::Base
  before_action :set_form_options

  def new
    @results = nil
  end

  # Ingests each direct-uploaded blob as a draft Image. Record creation is
  # DB-only and fast; EXIF fill / analyze / variants run in ProcessAttachedFileJob
  # so the request never downloads from S3. Failures are isolated per file so one
  # bad frame never aborts the rest of the roll; the result list says which failed.
  def create
    signed_ids = Array(params.dig(:bulk, :files)).compact_blank

    if signed_ids.empty?
      flash.now[:alert] = 'ファイルが選択されていません。'
      return render :new, status: :unprocessable_content
    end

    @results = signed_ids.map { |signed_id| ingest_draft(signed_id, shared_attributes) }
    respond_with_results
  end

  private

  def set_form_options
    @categories = Category.order(:name)
    @cameras = Camera.order(:manufacturer, :name)
    @lenses = Lens.order(:name)
  end

  # 全画像に共通で付ける属性。camera/lens は明示指定があれば EXIF より優先される
  # （モデルの EXIF 補完は空欄しか埋めないため、渡すだけで成立する）。
  def shared_attributes
    {
      category_ids: Array(params.dig(:bulk, :category_ids)).compact_blank,
      camera_id: params.dig(:bulk, :camera_id).presence,
      lens_id: params.dig(:bulk, :lens_id).presence
    }.compact
  end

  # 結果は { filename:, status: :created | :duplicate | :failed, image:, errors: }
  def ingest_draft(signed_id, shared_attributes)
    blob = ActiveStorage::Blob.find_signed!(signed_id)

    if (existing = Image.duplicate_for_blob(blob))
      # 重複分の direct-upload blob は不要なので回収する。ただし attach 済み
      # （同一 signed_id の二重 POST）の blob を消すと既存画像のファイルが消える
      blob.purge_later if blob.attachments.none?
      return { filename: blob.filename.to_s, status: :duplicate, image: existing, errors: [] }
    end

    persist_draft(blob, signed_id, shared_attributes)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    { filename: signed_id.to_s.truncate(24), status: :failed, image: nil,
      errors: ['アップロードが無効です（再アップロードしてください）'] }
  end

  def persist_draft(blob, signed_id, shared_attributes)
    image = Image.new(file: signed_id, is_published: false, **shared_attributes)
    if image.save
      { filename: blob.filename.to_s, status: :created, image: image, errors: [] }
    else
      # save 失敗時は未 attach の blob が S3 に残るため即時回収する
      blob.purge_later
      { filename: blob.filename.to_s, status: :failed, image: nil, errors: image.errors.full_messages }
    end
  end

  def respond_with_results
    counts = Hash.new(0).merge(@results.group_by { |r| r[:status] }.transform_values(&:size))

    if counts[:failed].zero?
      redirect_to admin_images_path(filter: "uncurated"), notice: import_notice(counts)
    else
      flash.now[:alert] = "#{counts[:failed]}枚の取り込みに失敗しました" \
                          "（成功 #{counts[:created]}枚・重複スキップ #{counts[:duplicate]}枚）。"
      render :new, status: :unprocessable_content
    end
  end

  def import_notice(counts)
    notice = "#{counts[:created]}枚を下書きとして取り込みました。"
    notice += "#{counts[:duplicate]}枚は取り込み済みのためスキップしました。" if counts[:duplicate].positive?
    "#{notice}EXIF・サムネイルはバックグラウンドで処理されます。1枚ずつタイトルを付けて公開してください。"
  end
end
