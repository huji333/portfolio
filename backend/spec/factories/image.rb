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
  end
end
