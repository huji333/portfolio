FactoryBot.define do
  factory :project do
    title { Faker::Lorem.sentence(word_count: 3) }
    link { Faker::Internet.url }
  end
end
