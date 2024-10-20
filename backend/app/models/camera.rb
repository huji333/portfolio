class Camera < ApplicationRecord
  has_many :images

  validates :name, presence: true
  validates :manufacturer, presence: true
end
