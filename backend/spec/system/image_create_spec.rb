require 'rails_helper'

RSpec.describe 'Image Create', type: :system do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let!(:camera) { create(:camera, name: 'Test Camera', manufacturer: 'Test Manufacturer') }
  let!(:lens) { create(:lens, name: 'Test Lens') }
  let!(:category) { create(:category, name: 'Test Category') }

  before do
    sign_in admin
  end

  it 'Should create image' do
    visit '/admin/images/new'
    fill_in 'image_title', with: 'Test Image'
    fill_in 'image_caption', with: 'Test Caption'
    fill_in 'image_taken_at', with: 1.day.ago
    fill_in 'image_display_order', with: '1'
    check 'image_is_published'
    select camera.name, from: 'image_camera_id'
    select lens.name, from: 'image_lens_id'
    check "image_category_ids_#{category.id}"
    attach_file 'image_file', Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')
    click_button '保存'

    # Debug: Check for any error messages
    if page.has_css?('.alert-danger')
      puts "Validation errors:"
      page.all('.alert-danger li').each do |error|
        puts "- #{error.text}"
      end
    end

    # Check for redirect to index page
    expect(page).to have_current_path('/admin/images')

    # Check for success notice
    expect(page).to have_content('Image was successfully created.')

    # Check if the image was created
    image = Image.last
    expect(image).to be_present

    # Check if the image was resized
    expect(image.file.metadata['width']).to be(1920)
  end
end
