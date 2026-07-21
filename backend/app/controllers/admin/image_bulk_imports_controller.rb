class Admin::ImageBulkImportsController < Admin::Base
  before_action :set_form_options

  # Cloudflare Tunnel の無料プランには 1 リクエスト 100MB のハード上限があるため、
  # それを超えないよう十分な余裕を持たせてアプリ側の上限をここに定義する。
  MAX_FILE_SIZE = 50.megabytes

  # vips が扱えるラスター形式のみ許可する。宣言された content_type と実バイト
  # （マジックバイト）の両方がこの一覧に含まれる場合のみ画像として受理し、
  # 偽装された Content-Type（実体は画像でないファイルが image/jpeg を名乗る等）を弾く。
  ACCEPTED_CONTENT_TYPES = %w[
    image/jpeg image/png image/webp image/heic image/heif image/tiff image/gif image/avif
  ].freeze

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
    failed = @results.count { |result| result[:status] == :failed }
    duplicates = @results.count { |result| result[:status] == :duplicate }
    created = @results.size - failed - duplicates

    if failed.zero? && duplicates.zero?
      redirect_to admin_images_path(filter: "uncurated"),
                  notice: "#{created}枚を下書きとして取り込みました。EXIF・サムネイルはバックグラウンドで処理されます。" \
                          "1枚ずつタイトルを付けて公開してください。"
    elsif failed.zero?
      flash.now[:notice] = "#{created}枚を下書きとして取り込みました（#{duplicates}枚は登録済みのため重複としてスキップしました）。"
      render :new, status: :ok
    else
      flash.now[:alert] = "#{failed}枚の取り込みに失敗しました（#{created}枚は成功、#{duplicates}枚は重複でスキップ）。"
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

  # checksum + byte_size が既存の Image#file と一致すれば重複としてスキップする。
  # direct upload は request 到達前に S3 アップロード済みなので、スキップ時・save 失敗時
  # は新規 blob を purge_later して孤立させない（同一バッチ内の重複も、前の反復の
  # image.save がここに来る前にコミット済みのため、この DB 照合だけで検出できる）。
  def ingest_draft(signed_id, shared_attributes)
    blob = ActiveStorage::Blob.find_signed!(signed_id)
    filename = blob.filename.to_s

    if (reason = blob_rejection_reason(blob))
      blob.purge_later
      return { filename: filename, status: :failed, image: nil, duplicate_image_id: nil, errors: [reason] }
    end

    if (duplicate = Image.attached_duplicate_for(blob))
      blob.purge_later
      return { filename: filename, status: :duplicate, image: nil, duplicate_image_id: duplicate.id, errors: [] }
    end

    image = Image.new(file: signed_id, is_published: false, **shared_attributes)
    if image.save
      { filename: filename, status: :created, image: image, duplicate_image_id: nil, errors: [] }
    else
      blob.purge_later
      { filename: filename, status: :failed, image: nil, duplicate_image_id: nil, errors: image.errors.full_messages }
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    { filename: signed_id.to_s.truncate(24), status: :failed, image: nil, duplicate_image_id: nil,
      errors: ['アップロードが無効です（再アップロードしてください）'] }
  end

  # サイズは direct upload 時点でメタデータとして分かっているので blob.byte_size を見るだけで済む。
  # 形式判定はサイズ超過より後回しにし、明らかに大きすぎるファイルでは byte range 取得すら行わない。
  # 先頭 4KB だけを ranged GET で取得して Marcel にマジックバイト判定させる（S3 からのフルダウンロードは避ける）。
  def blob_rejection_reason(blob)
    return 'サイズ上限50MBを超えています' if blob.byte_size > MAX_FILE_SIZE

    # declared_type は渡さない: Marcel は「マジックバイトで判定できない場合」に
    # declared_type へフォールバックしてしまい、それでは偽装された Content-Type を
    # そのまま信用することになる。ここではバイト由来の判定だけを独立して見る。
    header = blob.download_chunk(0...(4.kilobytes))
    detected_content_type = Marcel::MimeType.for(StringIO.new(header))

    if ACCEPTED_CONTENT_TYPES.include?(blob.content_type) && ACCEPTED_CONTENT_TYPES.include?(detected_content_type)
      return nil
    end

    '画像ではありません'
  end
end
