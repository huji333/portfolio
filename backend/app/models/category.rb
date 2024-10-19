class Category < ApplicationRecord
  has_many :image_categories
  has_many :images, through: :image_categories
end
