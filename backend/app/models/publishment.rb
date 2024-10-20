class Publishment < ApplicationRecord
  belongs_to :article

  validates :article_id, presence: true
  validates :published_at, presence: true
end
