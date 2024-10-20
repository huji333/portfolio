class Article < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }, _prefix: true

  has_many :publishments

  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: statuses.keys }
end
