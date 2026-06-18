module CdnAttachedFile
  extend ActiveSupport::Concern

  class MissingCdnBaseUrlError < StandardError; end

  included do
    after_commit :analyze_attached_file, on: %i[create update]
    after_commit :warm_variants, on: %i[create update]
  end

  def file_url
    return unless file.attached?

    build_cdn_url(file.key) || active_storage_url_for(file)
  end

  def thumbnail_variant = variant_for(thumbnail_limit)

  def thumbnail_url = variant_url(thumbnail_limit)
  def display_url = variant_url(display_limit)

  private

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

  def analyze_attached_file
    return unless file.attached?
    return if file.analyzed?

    file.analyze
  rescue ActiveStorage::FileNotFoundError => e
    log_file_not_found(:analyze_attached_file, e)
  rescue StandardError => e
    Rails.logger.error "analyze_attached_file failed (#{log_reference}): #{e.class} #{e.message}"
  end

  def warm_variants
    return unless file.attached?

    [thumbnail_limit, display_limit].each do |limit|
      variant = variant_for(limit)
      ensure_variant_processed(variant) if variant
    end
  rescue ActiveStorage::FileNotFoundError => e
    log_file_not_found(:warm_variants, e)
  rescue LoadError => e
    Rails.logger.warn "variant warm skipped (#{log_reference}): #{e.message}"
  rescue StandardError => e
    Rails.logger.error "variant warm error (#{log_reference}): #{e.full_message}"
  end

  def log_reference = "#{self.class.name.underscore} #{id}"

  def log_file_not_found(method, err)
    Rails.logger.error "#{method} failed (#{log_reference}): " \
                       "blob exists but file not in storage. #{err.class}: #{err.message}"
  end

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
    return nil unless Rails.env.test?

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

    with_variant_lock do
      variant.processed unless variant_generated?(variant)
    end

    variant
  rescue ActiveRecord::RecordNotUnique
    variant
  end

  def variant_generated?(variant)
    variant.respond_to?(:image) && variant.image&.attached?
  rescue NoMethodError
    false
  end

  def with_variant_lock(&) = persisted? ? with_lock(&) : yield
end
