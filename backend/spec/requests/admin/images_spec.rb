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

  describe 'POST /admin/images/extract_exif' do
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    it 'resolves and auto-creates camera/lens and returns taken_at' do
      expect do
        post '/admin/images/extract_exif', params: { signed_id: blob.signed_id }
      end.to change(Camera, :count).by(1).and change(Lens, :count).by(1)

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body.dig('camera', 'label')).to eq('SONY ILCE-7CM2')
      expect(body.dig('lens', 'label')).to eq('FE 85mm F1.8')
      expect(body['taken_at']).to eq('2024-01-01T03:56')
    end

    it 'fails open with nulls for an invalid signed id' do
      post '/admin/images/extract_exif', params: { signed_id: 'bogus' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to eq('taken_at' => nil, 'camera' => nil, 'lens' => nil)
    end
  end
end
