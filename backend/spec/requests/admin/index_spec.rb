require 'rails_helper'

RSpec.describe 'Admin::Index (dashboard)', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin' do
    it 'links to all five sections (画像・カテゴリ・プロジェクト・機材・一括取り込み)' do
      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(admin_images_path)
      expect(response.body).to include(admin_categories_path)
      expect(response.body).to include(admin_projects_path)
      expect(response.body).to include(admin_cameras_path)
      expect(response.body).to include(admin_lenses_path)
      expect(response.body).to include(new_admin_image_bulk_import_path)
    end

    it 'surfaces published / draft / uncurated stats and links uncurated to the filtered list' do
      create_list(:image, 2) # published
      create(:image, is_published: false, title: 'Kept draft') # draft but curated (title present)
      create(:image, :draft) # draft + uncurated (blank title)

      get admin_root_path

      expect(response).to have_http_status(:success)
      # published=2, draft=2, uncurated=1
      expect(response.body).to include('公開')
      expect(response.body).to include('未編集')
      expect(response.body).to include('下書き')
      # 未編集カウントから uncurated フィルタ済み一覧へ飛べる（完了条件）
      expect(response.body).to include(admin_images_path(filter: 'uncurated'))
    end
  end
end
