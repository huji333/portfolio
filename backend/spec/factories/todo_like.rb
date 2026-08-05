FactoryBot.define do
  factory :todo_like do
    todo_item
    device_uuid { SecureRandom.uuid }
  end
end
