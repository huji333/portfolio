FactoryBot.define do
  factory :image do
    sequence(:title) { |n| "MyString #{n}" }
    caption { "MyString" }
    taken_at { "2024-10-19 13:23:39" }
    display_order { 1 }
    is_published { false }
    association :camera
    association :lens

    after(:build) do |image|
      image.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample.jpg")),
        filename: 'sample.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
