class Lens < ApplicationRecord
  has_many :images, dependent: :restrict_with_error

  validates :name, presence: true

  # Resolve (and auto-create) a Lens from the raw EXIF LensModel string. The raw
  # value is the natural key; display name defaults to it and is edited later in
  # admin. Returns nil when EXIF lacks a LensModel (fail-open).
  def self.resolve_from_exif(exif_name)
    return nil if exif_name.blank?

    find_or_create_by!(exif_name: exif_name) { |lens| lens.name = exif_name }
  end
end
