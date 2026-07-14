module CdnAttachedFile
  extend ActiveSupport::Concern

  class MissingCdnBaseUrlError < StandardError; end

  included do
    # analyze / variant 生成は S3 ダウンロードを伴うためリクエスト内では行わず、
    # ジョブに退避する（大量一括取込でのタイムアウト回避）。
    after_commit :enqueue_attached_file_processing, on: %i[create update]
  end

  # ProcessAttachedFileJob から呼ばれる。リクエスト経路の variant_url と違い
  # rescue しない（fail-loud）：失敗は Solid Queue の failed executions に残る。
  def process_attached_file!
    return unless file.attached?

    file.analyze unless file.analyzed?
    variant_limits.each { |limit| ensure_variant_processed(variant_for(limit)) }
    after_attached_file_processed
  end

  # variant 生成後・同一ジョブ内で呼ばれるモデル固有の後処理フック（デフォルト no-op）。
  # variants-before-save の順序保証はここに集約する（Image は EXIF 補完を差し込む）。
  def after_attached_file_processed; end

  def thumbnail_variant = variant_for(thumbnail_limit)

  def thumbnail_url = variant_url(thumbnail_limit)
  def display_url = variant_url(display_limit)

  private

  def file_url
    return unless file.attached?

    build_cdn_url(file.key) || active_storage_url_for(file)
  end

  def variant_for(limit)
    return unless file.attached?

    file.variant(resize_to_limit: limit)
  end

  def variant_url(limit)
    variant = variant_for(limit)
    return unless variant

    ensure_variant_processed(variant)

    build_cdn_url(variant.key) || active_storage_url_for(variant)
  rescue StandardError, LoadError => e
    Rails.logger.warn "variant_url fallback (#{log_reference}): #{e.class} #{e.message}"
    file_url
  end

  def thumbnail_limit = self.class::THUMBNAIL_LIMIT
  def display_limit = self.class::DISPLAY_LIMIT

  # 後処理・再エンキュー判定の両方が参照する variant サイズの単一ソース。
  def variant_limits = [thumbnail_limit, display_limit]

  def enqueue_attached_file_processing
    return unless attached_file_needs_processing?

    ProcessAttachedFileJob.perform_later(self)
  end

  # 導出で判定する（処理状態カラムは持たない）。analyze 済み・variant 生成済みなら
  # 保存しても再エンキューされず、ジョブ内の save で連鎖が止まる。
  def attached_file_needs_processing?
    return false unless file.attached?

    !file.analyzed? ||
      variant_limits.any? { |limit| !variant_generated?(variant_for(limit)) }
  end

  def log_reference = "#{self.class.name.underscore} #{id}"

  def build_cdn_url(key)
    (base = cdn_base_url) ? "#{base}/#{key}" : nil
  end

  def cdn_base_url
    url = Rails.configuration.cdn_base_url.presence
    return url if url

    if Rails.env.production?
      raise(MissingCdnBaseUrlError,
            "CLOUDFRONT_BASE_URL must be set to generate CDN-backed file URLs")
    end

    nil
  end

  def active_storage_url_for(attachable)
    return nil unless Rails.env.local?

    helpers = Rails.application.routes.url_helpers
    host = ENV.fetch("ACTIVE_STORAGE_HOST", "http://localhost:3000")

    case attachable
    when ActiveStorage::Attached::One
      helpers.rails_blob_url(attachable.blob, host: host) if attachable.attached?
    when ActiveStorage::Attachment, ActiveStorage::Blob
      blob = attachable.is_a?(ActiveStorage::Attachment) ? attachable.blob : attachable
      helpers.rails_blob_url(blob, host: host)
    when ActiveStorage::VariantWithRecord, ActiveStorage::Variant
      helpers.rails_representation_url(attachable, host: host)
    end
  rescue StandardError => e
    Rails.logger.warn "active_storage_url_for fallback failed: #{e.class} #{e.message}"
    nil
  end

  def ensure_variant_processed(variant)
    return variant if variant_generated?(variant)

    # NOTE: must NOT run inside with_lock/transaction. Processing a variant inside an
    # open transaction makes the image_processing output Tempfile get GC-unlinked before
    # S3Service#upload reads its size (Errno::ENOENT @ rb_file_s_size /tmp/image_processing*),
    # so the VariantRecord is persisted but its S3 object is empty -> CloudFront 403.
    # variant.processed (VariantWithRecord) is concurrency-safe via create_or_find_by!,
    # and RecordNotUnique below covers the race, so no explicit lock is needed.
    variant.processed

    variant
  rescue ActiveRecord::RecordNotUnique
    variant
  end

  def variant_generated?(variant)
    variant.respond_to?(:image) && variant.image&.attached?
  rescue NoMethodError
    false
  end
end
