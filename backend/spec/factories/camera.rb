FactoryBot.define do
  factory :camera do
    name { Faker::Lorem.word }
    manufacturer { Faker::Lorem.word }
  end
end
