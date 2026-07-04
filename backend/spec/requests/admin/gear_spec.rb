require 'rails_helper'

RSpec.describe 'Admin::Gear', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin/gear' do
    it 'lists cameras and lenses on a single page' do
      create(:camera, name: 'X-T5', manufacturer: 'FUJIFILM')
      create(:lens, name: 'XF35mmF1.4 R')

      get admin_gear_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('X-T5')
      expect(response.body).to include('FUJIFILM')
      expect(response.body).to include('XF35mmF1.4 R')
    end

    it 'badges uncurated gear (EXIF display values not yet edited)' do
      create(:camera, make: 'SONY', model: 'ILCE-7M4', manufacturer: 'SONY', name: 'ILCE-7M4')

      get admin_gear_path

      expect(response.body).to include('未整備')
    end

    it 'renders per-gear usage counts' do
      camera = create(:camera, name: 'X-T5', manufacturer: 'FUJIFILM')
      create_list(:image, 3, camera: camera)

      get admin_gear_path

      expect(response).to have_http_status(:success)
      # 使用枚数セルに 3 が出る（グループクエリ集計）
      expect(response.body).to match(/3/)
    end
  end

  describe 'standalone camera/lens index routes are removed', type: :routing do
    it 'no longer routes GET /admin/cameras' do
      expect(get: '/admin/cameras').not_to be_routable
    end

    it 'no longer routes GET /admin/lenses' do
      expect(get: '/admin/lenses').not_to be_routable
    end
  end

  describe 'save redirects point at the gear view' do
    it 'redirects camera create to gear' do
      post admin_cameras_path, params: { camera: { name: 'X100V', manufacturer: 'FUJIFILM' } }
      expect(response).to redirect_to(admin_gear_path)
    end

    it 'redirects lens create to gear' do
      post admin_lenses_path, params: { lens: { name: 'XF16mmF1.4 R' } }
      expect(response).to redirect_to(admin_gear_path)
    end
  end
end
