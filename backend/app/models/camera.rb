class Camera < ApplicationRecord
  has_many :images, dependent: :restrict_with_error

  validates :name, presence: true
  validates :manufacturer, presence: true

  def self.lookup(camera_name, manufacturer)
    return nil if camera_name.blank? && manufacturer.blank?

    # カメラ名とメーカー名の両方が提供されている場合
    if camera_name.present? && manufacturer.present?
      camera = where("LOWER(name) LIKE ? AND LOWER(manufacturer) LIKE ?",
                     "%#{sanitize_sql_like(camera_name.downcase)}%",
                     "%#{sanitize_sql_like(manufacturer.downcase)}%").first
      return camera if camera
    end

    # カメラ名のみで検索
    if camera_name.present?
      camera = where("LOWER(name) LIKE ?", "%#{sanitize_sql_like(camera_name.downcase)}%").first
      return camera if camera
    end

    # メーカー名のみで検索
    if manufacturer.present?
      camera = where("LOWER(manufacturer) LIKE ?", "%#{sanitize_sql_like(manufacturer.downcase)}%").first
      return camera if camera
    end

    nil
  end
end
