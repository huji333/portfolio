require 'rails_helper'
RSpec.describe 'Admin::Projects', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  describe 'POST /admin/projects' do
    it 'attaches the uploaded image' do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/test_image.jpg'), 'image/jpeg')

      expect do
        post admin_projects_path, params: { project: { title: 'Sample Project', link: 'https://example.com', file: file } }
      end.to change(Project, :count).by(1)

      expect(response).to redirect_to(admin_projects_path)

      project = Project.order(:created_at).last
      expect(project.file).to be_attached

      expect(project.file).to be_attached
    end
  end
end
