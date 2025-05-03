class Image < ApplicationRecord
  has_many :image_categories, dependent: :destroy
  has_many :categories, through: :image_categories
  belongs_to :camera
  belongs_to :lens

  has_one_attached :file

  validates :file, presence: true
  validates :title, presence: true
  validates :caption, presence: true
  validates :taken_at, presence: true
  validates :display_order, presence: true
  validates :is_published, inclusion: { in: [true, false] }

  validate :taken_at_is_in_the_past

  def self.resize_io(io)
    require 'image_processing/vips'
    ImageProcessing::Vips
      .source(io)
      .resize_to_limit(1920, 1920)
      .convert('jpg')
      .call
  end

  private

  def taken_at_is_in_the_past
    return if taken_at.nil?

    errors.add(:taken_at, 'must be in the past') if taken_at > Time.zone.now
  end
end
