FactoryBot.define do
  factory :bucket_list_item do
    title { Faker::Lorem.sentence(word_count: 3) }
    position { 0 }
  end
end
