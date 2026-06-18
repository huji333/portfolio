# Extracts camera/lens/timestamp facts from an image's EXIF using ruby-vips
# (already a dependency — no extra gem). All failures are swallowed and surfaced
# as nil so a missing/corrupt EXIF never blocks an upload (fail-open).
class ExifExtractor
  Result = Data.define(:make, :model, :lens_model, :taken_at)
  EMPTY = Result.new(make: nil, model: nil, lens_model: nil, taken_at: nil)

  FIELDS = {
    make: "exif-ifd0-Make",
    model: "exif-ifd0-Model",
    lens_model: "exif-ifd2-LensModel",
    date_time_original: "exif-ifd2-DateTimeOriginal",
    offset_time_original: "exif-ifd2-OffsetTimeOriginal"
  }.freeze

  def self.from_blob(blob)
    new(blob.download).call
  rescue StandardError => e
    Rails.logger.warn "ExifExtractor.from_blob failed: #{e.class} #{e.message}"
    EMPTY
  end

  def initialize(buffer)
    @image = Vips::Image.new_from_buffer(buffer, "")
  end

  def call
    Result.new(
      make: field(:make),
      model: field(:model),
      lens_model: field(:lens_model),
      taken_at: parse_taken_at
    )
  rescue StandardError => e
    Rails.logger.warn "ExifExtractor#call failed: #{e.class} #{e.message}"
    EMPTY
  end

  private

  def field(key)
    sanitize(@image.get(FIELDS[key]))
  rescue Vips::Error
    nil
  end

  # vips returns values like "SONY (SONY, ASCII, 5 components, 5 bytes)" — strip
  # the trailing type description and return nil for blanks.
  def sanitize(value)
    return nil unless value.is_a?(String)

    value.sub(/\s*\([^()]*\)\s*\z/, "").strip.presence
  end

  def parse_taken_at
    raw = field(:date_time_original)
    return nil if raw.blank?

    match = raw.match(/\A(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})\z/)
    return nil unless match

    parts = match.captures.map(&:to_i)
    offset = field(:offset_time_original)
    if offset&.match?(/\A[+-]\d{2}:\d{2}\z/)
      Time.new(*parts, offset).in_time_zone
    else
      Time.zone.local(*parts)
    end
  rescue ArgumentError
    nil
  end
end
