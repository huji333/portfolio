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

  describe 'GET /admin/images' do
    it 'renders and surfaces the uncurated draft count with a filter link' do
      create(:image, :draft, row_order: 500)

      get '/admin/images'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('未編集の下書きが 1 枚あります')
    end

    it 'filters to uncurated drafts only' do
      draft = create(:image, :draft, row_order: 500)

      get '/admin/images', params: { filter: 'uncurated' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("data-image-id='#{draft.id}'").or include("data-image-id=\"#{draft.id}\"")
    end
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

  describe 'PATCH /admin/images/:id with save_and_next' do
    let!(:draft_a) { create(:image, :draft, row_order: 500) }
    let!(:draft_b) { create(:image, :draft, row_order: 600) }

    it 'redirects to the next uncurated draft after saving' do
      patch "/admin/images/#{draft_a.id}",
            params: { save_and_next: '1', image: { title: 'Titled now' } }

      expect(response).to redirect_to(edit_admin_image_path(draft_b))
    end

    it 'redirects to the index when no uncurated drafts remain' do
      draft_b.update!(title: 'already titled')

      patch "/admin/images/#{draft_a.id}",
            params: { save_and_next: '1', image: { title: 'Titled now' } }

      expect(response).to redirect_to(admin_images_path)
    end

    it 'keeps the normal redirect when save_and_next is absent' do
      patch "/admin/images/#{draft_a.id}", params: { image: { title: 'Titled now' } }

      expect(response).to redirect_to(admin_images_path(draft_a, format: nil))
    end
  end
end
