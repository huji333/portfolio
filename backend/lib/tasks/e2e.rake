namespace :e2e do
  desc 'Seed data for Playwright e2e tests (run after db:test:prepare)'
  task seed: :environment do
    puts 'Seeding e2e test data...'

    # Suppress CdnAttachedFile callbacks that try to process variants
    # (thumbnail variant generation fails when the disk file is still being written)
    Image.skip_callback(:commit, :after, :warm_thumbnail_variant, raise: false)
    Image.skip_callback(:commit, :after, :analyze_attached_file, raise: false)
    Project.skip_callback(:commit, :after, :warm_thumbnail_variant, raise: false)
    Project.skip_callback(:commit, :after, :analyze_attached_file, raise: false)

    # Users
    User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: :admin)
    User.create!(email: 'guest@example.com', password: 'password123', password_confirmation: 'password123', role: :guest)

    # Camera & Lens (matching EXIF in test_image.jpg)
    camera = Camera.create!(name: 'a7C II', manufacturer: 'SONY')
    lens = Lens.create!(name: 'FE 85mm F1.8')

    # Category
    category = Category.create!(name: 'E2E Test Category')

    # Sample images
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
      image.file.attach(
        io: File.open(test_image_path),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
      image.categories << category
      image.save!

    end

    # Analyze blobs and generate thumbnail variants
    Image.where('title LIKE ?', 'Seed Image%').find_each do |image|
      image.file.analyze unless image.file.analyzed?
      # Generate thumbnail variant so representation URLs work
      variant = image.thumbnail_variant
      variant.processed if variant
      puts "  #{image.title}: file=#{image.file.service.exist?(image.file.key)} meta=#{image.file.metadata}"
    end

    # Project
    project = Project.new(title: 'E2E Test Project', link: 'https://example.com/e2e')
    project.file.attach(
      io: File.open(test_image_path),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
    project.save!

    puts 'E2E seed data created successfully.'
  end
end
