class Camera < ApplicationRecord
  has_many :images, dependent: :restrict_with_error

  validates :name, presence: true
  validates :manufacturer, presence: true

  # Resolve (and auto-create) a Camera from raw EXIF Make/Model. The raw values are
  # the natural key; display name/manufacturer default to the raw values and are
  # edited later in admin. Returns nil when EXIF lacks make/model (fail-open).
  def self.resolve_from_exif(make:, model:)
    return nil if make.blank? || model.blank?

    find_or_create_by!(make: make, model: model) do |camera|
      camera.manufacturer = make
      camera.name = model
    end
  end

  def display_label
    "#{manufacturer} #{name}".strip
  end
end
