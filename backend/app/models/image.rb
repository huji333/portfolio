class Image < ApplicationRecord
  has_many :image_categories
  has_many :categories through: :image_categories
  belongs_to :camera
  belongs_to :lens
end
