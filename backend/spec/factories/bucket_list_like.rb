FactoryBot.define do
  factory :bucket_list_like do
    bucket_list_item
    device_uuid { SecureRandom.uuid }
  end
end
