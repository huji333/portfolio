module CdnAttachedFile
  extend ActiveSupport::Concern

  MissingCdnBaseUrlError = Class.new(StandardError)

  included do
    after_commit :analyze_attached_file, on: %i[create update]
    after_commit :warm_thumbnail_variant, on: %i[create update]
  end

  def file_url
    return unless file.attached?

    build_cdn_url(file.key)
  end

  def thumbnail_variant
    return unless file.attached?

    file.variant(resize_to_limit: thumbnail_limit)
  end

  def thumbnail_url
    variant = thumbnail_variant
    return unless variant

    build_cdn_url(variant.key)
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

    thumbnail_variant&.process_later
  rescue StandardError => e
    Rails.logger.error "thumbnail_variant error (#{log_reference}): #{e.full_message}"
  end

  def log_reference
    "#{self.class.name.underscore} #{id}"
  end

  def build_cdn_url(key)
    "#{cdn_base_url}/#{key}"
  end

  def cdn_base_url
    Rails.configuration.cdn_base_url.presence ||
      raise(MissingCdnBaseUrlError, "CLOUDFRONT_BASE_URL must be set to generate CDN-backed file URLs")
  end
end
