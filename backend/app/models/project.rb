class Project < ApplicationRecord
  has_one_attached :file

  validates :name, presence: true
  validates :description, presence: true
end
