class Image < ApplicationRecord
  has_many :image_categories
  has_many :categories through: :image_categories
  belongs_to :camera
  belongs_to :lens

  has_one_attached :file

  validates :file, presence: true
  validates :title, presence: true
  validates :caption, presence: true
  validates :taken_at, presence: true
  validates :camera, presence: true
  validates :lens, presence: true
  validates :display_order, presence: true
  validates :is_published, inclusion: { in: [true, false] }

  validate :taken_at_is_in_the_past

  private

  def taken_at_is_in_the_past
    return if taken_at.nil?
    if taken_at > Time.zone.now
      errors.add(:taken_at, "can't be in the future")
    end
  end
end
