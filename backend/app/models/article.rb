class Article < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }

  has_many :publishments
end
