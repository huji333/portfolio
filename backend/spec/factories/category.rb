FactoryBot.define do
  factory :category do
    # name は一意制約あり。Faker::Lorem.word は語彙が少なく同一 example 内で衝突するので連番を足す
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
  end
end
