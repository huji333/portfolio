require 'rails_helper'

RSpec.describe 'Admin::Images', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before do
    sign_in user
    create(:image, title: 'Test Image 1', row_order: 100, id: 1)
    create(:image, title: 'Test Image 2', row_order: 200, id: 2)
    create(:image, title: 'Test Image 3', row_order: 300, id: 3)
    create(:image, title: 'Test Image 4', row_order: 400, id: 4)
  end

  describe 'POST /admin/images/:id/insert_at' do
    it 'should insert the image at the given position' do
      expect(Image.rank(:row_order).pluck(:id)).to eq([1, 2, 3, 4])

      post "/admin/images/1/insert_at", params: { position: 2 }
      expect(response).to have_http_status(:success)

      expect(Image.rank(:row_order).pluck(:id)).to eq([2, 3, 1, 4])
    end
  end
end
