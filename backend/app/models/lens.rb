class Lens < ApplicationRecord
  has_many :images, dependent: :restrict_with_error

  validates :name, presence: true
end
