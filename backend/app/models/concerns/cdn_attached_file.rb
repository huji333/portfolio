module CdnAttachedFile
  extend ActiveSupport::Concern

  class MissingCdnBaseUrlError < StandardError
  end

  included do
    after_commit :analyze_attached_file, on: %i[create update]
    after_commit :warm_thumbnail_variant, on: %i[create update]
  end

  def file_url
    return unless file.attached?

    build_cdn_url(file.key) || active_storage_url_for(file)
  end

  def thumbnail_variant
    return unless file.attached?

    file.variant(resize_to_limit: thumbnail_limit)
  end

  def thumbnail_url
    variant = thumbnail_variant
    return unless variant

    ensure_thumbnail_variant_processed(variant)

    build_cdn_url(variant.key) || active_storage_url_for(variant)
  rescue StandardError, LoadError => e
    Rails.logger.warn "thumbnail_url fallback (#{log_reference}): #{e.class} #{e.message}"
    file_url
  end

  private

  def thumbnail_limit
    self.class::THUMBNAIL_LIMIT
  end

  def analyze_attached_file
    return unless file.attached?
    return if file.analyzed?

    file.analyze
  rescue StandardError => e
    Rails.logger.warn "analyze_attached_file skipped (#{log_reference}): #{e.class} #{e.message}"
  end

  def warm_thumbnail_variant
    return unless file.attached?

    variant = thumbnail_variant
    return if variant.blank?

    ensure_thumbnail_variant_processed(variant)
  rescue LoadError => e
    Rails.logger.warn "thumbnail_variant skipped (#{log_reference}): #{e.message}"
  rescue StandardError => e
    Rails.logger.error "thumbnail_variant error (#{log_reference}): #{e.full_message}"
  end

  def log_reference
    "#{self.class.name.underscore} #{id}"
  end

  def build_cdn_url(key)
    base = cdn_base_url
    return nil if base.nil?

    "#{base}/#{key}"
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
    host = ENV.fetch("ACTIVE_STORAGE_HOST", "http://localhost:3100")

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

  def ensure_thumbnail_variant_processed(variant)
    return variant if thumbnail_variant_generated?(variant)

    with_thumbnail_lock do
      variant.processed unless thumbnail_variant_generated?(variant)
    end

    variant
  rescue ActiveRecord::RecordNotUnique
    variant
  end

  def thumbnail_variant_generated?(variant)
    variant.respond_to?(:image) && variant.image&.attached?
  rescue NoMethodError
    false
  end

  def with_thumbnail_lock(&)
    if persisted?
      with_lock(&)
    else
      yield
    end
  end
end
