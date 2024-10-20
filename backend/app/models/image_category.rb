class ImageCategory < ApplicationRecord
  belongs_to :image
  belongs_to :category

  validates :image_id, presence: true
  validates :category_id, presence: true
end
