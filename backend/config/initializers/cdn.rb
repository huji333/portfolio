# frozen_string_literal: true

require "uri"

Rails.application.configure do
  raw_base_url = ENV["CLOUDFRONT_BASE_URL"]&.strip

  if raw_base_url.blank?
    raise "CLOUDFRONT_BASE_URL must be set to boot the application" if Rails.env.production?

    Rails.logger.warn "[cdn] CLOUDFRONT_BASE_URL is not set; CDN URLs will be unavailable" if defined?(Rails.logger)
    config.cdn_base_url = nil
    next
  end

  normalized_base_url = raw_base_url.delete_suffix("/")

  begin
    uri = URI.parse(normalized_base_url)
  rescue URI::InvalidURIError => e
    raise "CLOUDFRONT_BASE_URL must be a valid absolute URL: #{e.message}"
  end

  raise "CLOUDFRONT_BASE_URL must be an HTTP(S) URL with a hostname (was #{raw_base_url.inspect})" unless uri.is_a?(URI::HTTP) && uri.host.present?

  config.cdn_base_url = normalized_base_url.freeze
end
