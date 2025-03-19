FactoryBot.define do
  factory :camera do
    sequence(:name) { |n| "Camera Model #{n}" }
    manufacturer { "Test Manufacturer" }
  end
end
