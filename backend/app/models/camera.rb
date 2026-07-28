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

  # EXIF 自動生成のまま表示名を整えていない機材を「未整備」とする。
  # 手動作成（make/model が blank）は整備済み扱い。
  # 判定はこの述語が single source（SQL scope を併置すると blank の解釈がズレる）。
  def uncurated?
    make.present? && model.present? && manufacturer == make && name == model
  end
end
