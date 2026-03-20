namespace :e2e do
  desc 'Seed data for Playwright e2e tests (run after db:test:prepare)'
  task seed: :environment do
    seed_users
    camera, lens = seed_camera_and_lens
    category = Category.create!(name: 'E2E Test Category')
    seed_images(camera, lens, category)
    seed_project

    puts 'E2E seed data created successfully.'
  end
end

def seed_users
  pw = 'password123'
  User.create!(email: 'admin@example.com', password: pw,
               password_confirmation: pw, role: :admin)
  User.create!(email: 'guest@example.com', password: pw,
               password_confirmation: pw, role: :guest)
end

def seed_camera_and_lens
  camera = Camera.create!(name: 'a7C II', manufacturer: 'SONY')
  lens = Lens.create!(name: 'FE 85mm F1.8')
  [camera, lens]
end

def seed_images(camera, lens, category)
  suppress_cdn_callbacks

  test_image_path = Rails.root.join('spec/fixtures/files/test_image.jpg')

  3.times do |i|
    image = Image.new(
      title: "Seed Image #{i + 1}",
      caption: "E2E test image #{i + 1}",
      taken_at: Time.zone.today - i.days,
      row_order: i,
      is_published: true,
      camera: camera,
      lens: lens
    )
    image.file.attach(io: File.open(test_image_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
    image.categories << category
    image.save!
  end

  analyze_and_warm_variants
end

def seed_project
  test_image_path = Rails.root.join('spec/fixtures/files/test_image.jpg')
  project = Project.new(title: 'E2E Test Project', link: 'https://example.com/e2e')
  project.file.attach(io: File.open(test_image_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
  project.save!
end

def suppress_cdn_callbacks
  Image.skip_callback(:commit, :after, :warm_thumbnail_variant, raise: false)
  Image.skip_callback(:commit, :after, :analyze_attached_file, raise: false)
  Project.skip_callback(:commit, :after, :warm_thumbnail_variant, raise: false)
  Project.skip_callback(:commit, :after, :analyze_attached_file, raise: false)
end

def analyze_and_warm_variants
  Image.where('title LIKE ?', 'Seed Image%').find_each do |image|
    image.file.analyze unless image.file.analyzed?
    image.thumbnail_variant&.processed
    puts "  #{image.title}: file=#{image.file.service.exist?(image.file.key)} meta=#{image.file.metadata}"
  end
end
