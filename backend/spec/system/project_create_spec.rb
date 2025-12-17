require 'rails_helper'
require 'mini_magick'

RSpec.describe 'Project management', type: :system do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  it 'creates a project and resizes the attachment to the configured width', js: true do
    visit '/admin/projects/new'

    fill_in 'project_title', with: 'System Spec Project'
    fill_in 'project_link', with: 'https://example.com/system-spec'
    attach_file 'project_file', Rails.root.join('spec/fixtures/files/test_image.jpg')

    expect(page).to have_css('[data-image-upload-target="status"]', text: '✓ アップロード完了', wait: 10)

    click_button '保存'

    expect(page).to have_current_path('/admin/projects')
    expect(page).to have_content('Project was successfully created.')

    project = Project.order(:created_at).last
    expect(project.title).to eq('System Spec Project')

    project.file.blob.open do |tempfile|
      processed = MiniMagick::Image.new(tempfile.path)
      expect(processed.width).to eq(720)
    end
  end
end
