# frozen_string_literal: true

require "uri"

Rails.application.configure do
  raw_base_url = ENV["CLOUDFRONT_BASE_URL"]&.strip
  raise "CLOUDFRONT_BASE_URL must be set to boot the application" if raw_base_url.blank?

  normalized_base_url = raw_base_url.delete_suffix("/")

  begin
    uri = URI.parse(normalized_base_url)
  rescue URI::InvalidURIError => e
    raise "CLOUDFRONT_BASE_URL must be a valid absolute URL: #{e.message}"
  end

  raise "CLOUDFRONT_BASE_URL must be an HTTP(S) URL with a hostname (was #{raw_base_url.inspect})" unless uri.is_a?(URI::HTTP) && uri.host.present?

  config.cdn_base_url = normalized_base_url.freeze
end
