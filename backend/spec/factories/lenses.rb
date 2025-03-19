FactoryBot.define do
  factory :lens do
    sequence(:name) { |n| "Lens Model #{n}" }
  end
end
