FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    role { 'guest' }

    trait :admin do
      role { 'admin' }
    end
  end
end
