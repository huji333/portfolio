FactoryBot.define do
  factory :image do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), 'image/jpeg') }
    title { Faker::Lorem.word }
    caption { Faker::Lorem.sentence }
    taken_at { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    row_order { 1 }
    is_published { true }
    camera { build(:camera) }
    lens { build(:lens) }

    # Fresh bulk-ingested state: nothing curated yet, metadata to be filled by EXIF.
    trait :draft do
      title { nil }
      caption { nil }
      taken_at { nil }
      is_published { false }
      camera { nil }
      lens { nil }
    end
  end
end
