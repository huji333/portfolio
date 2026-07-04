require 'rails_helper'

RSpec.describe 'Admin::Index (dashboard)', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin' do
    it 'renders the three work launchers (取り込む・編纂する・並べる)' do
      get admin_root_path

      expect(response).to have_http_status(:success)
      # 取り込む → 一括取り込み / 編纂する → 未編集フィルタ / 並べる → 並び替え画面
      expect(response.body).to include(new_admin_image_bulk_import_path)
      expect(response.body).to include(admin_images_path(filter: 'uncurated'))
      expect(response.body).to include(arrange_admin_images_path)
    end

    it 'renders the three master links (機材・カテゴリ・プロジェクト)' do
      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(admin_gear_path)
      expect(response.body).to include(admin_categories_path)
      expect(response.body).to include(admin_projects_path)
    end

    it 'surfaces the remaining uncurated draft count as a badge on the 編纂する launcher' do
      create_list(:image, 2) # published
      create(:image, is_published: false, title: 'Kept draft') # draft but curated (title present)
      create(:image, :draft) # draft + uncurated (blank title) → 残1件

      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('残 1 件')
    end

    it 'counts only uncurated gear (EXIF display values not yet edited) for the 機材 badge' do
      create(:camera, make: 'SONY', model: 'ILCE-7M4', manufacturer: 'SONY', name: 'ILCE-7M4') # uncurated
      create(:camera, name: 'X-T5', manufacturer: 'FUJIFILM') # curated (no make/model)
      create(:lens, exif_name: 'XF35mmF1.4 R', name: 'XF35mmF1.4 R') # uncurated

      get admin_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('未整備 2')
    end
  end
end
