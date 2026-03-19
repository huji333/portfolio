class Category < ApplicationRecord
  has_many :image_categories, dependent: :destroy
  has_many :images, through: :image_categories

  validates :name, presence: true
end
