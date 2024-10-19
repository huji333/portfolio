class Camera < ApplicationRecord
  has_many :images

  validates :name, presence: true, uniqueness: true
  validates :manufacturer, presence: true
end
