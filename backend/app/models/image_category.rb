class ImageCategory < ApplicationRecord
  belongs_to :image
  belongs_to :category
end
