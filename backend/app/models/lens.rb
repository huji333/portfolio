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

  # EXIF 自動生成のまま表示名を整えていない機材を「未整備」とする。
  # 手動作成（exif_name が blank）は整備済み扱い。
  scope :uncurated, lambda {
    where.not(exif_name: [nil, ""]).where("name = exif_name")
  }

  def uncurated?
    exif_name.present? && name == exif_name
  end
end
