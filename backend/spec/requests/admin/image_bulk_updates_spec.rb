require 'rails_helper'

RSpec.describe 'Admin::ImageBulkUpdates', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }
  let!(:image1) { create(:image, title: 'Test Image 1') }
  let!(:image2) { create(:image, title: 'Test Image 2') }
  let!(:image3) { create(:image, title: 'Test Image 3') }
  let(:camera) { create(:camera) }
  let(:lens) { create(:lens) }
  let(:category) { create(:category) }

  before { sign_in user }

  describe 'PATCH /admin/image_bulk_update' do
    it 'assigns camera, lens, and categories to the selected images only' do
      patch '/admin/image_bulk_update',
            params: { image_ids: [image1.id, image2.id],
                      camera_id: camera.id, lens_id: lens.id, category_ids: [category.id] }

      expect(response).to redirect_to(admin_images_path)
      expect(flash[:notice]).to include('2枚')
      expect(image1.reload).to have_attributes(camera: camera, lens: lens)
      expect(image1.categories).to eq([category])
      expect(image2.reload.camera).to eq(camera)
      # 未選択の画像は触らない（factory が付けた元のカメラのまま）
      expect(image3.reload.camera).not_to eq(camera)
    end

    it 'leaves blank fields untouched（空欄 = 変更しない）' do
      original_lens = create(:lens)
      image1.update!(lens: original_lens)

      patch '/admin/image_bulk_update', params: { image_ids: [image1.id], camera_id: camera.id }

      expect(image1.reload.camera).to eq(camera)
      expect(image1.lens).to eq(original_lens)
    end

    it 'adds categories to existing ones without duplicates（union）' do
      existing = create(:category)
      image1.categories << existing
      image1.categories << category

      expect do
        patch '/admin/image_bulk_update',
              params: { image_ids: [image1.id], category_ids: [category.id] }
      end.not_to change(ImageCategory, :count)

      expect(image1.reload.categories).to contain_exactly(existing, category)
    end

    it 'preserves the uncurated filter on redirect' do
      patch '/admin/image_bulk_update',
            params: { image_ids: [image1.id], camera_id: camera.id, filter: 'uncurated' }

      expect(response).to redirect_to(admin_images_path(filter: 'uncurated'))
    end

    it 'rejects an empty selection with an alert' do
      patch '/admin/image_bulk_update', params: { camera_id: camera.id }

      expect(response).to redirect_to(admin_images_path)
      expect(flash[:alert]).to include('画像が選択されていません')
    end

    it 'rejects a submission with nothing to apply' do
      expect do
        patch '/admin/image_bulk_update', params: { image_ids: [image1.id] }
      end.not_to(change { image1.reload.camera_id })

      expect(response).to redirect_to(admin_images_path)
      expect(flash[:alert]).to include('適用する項目')
    end

    it 'fails loudly when an unknown image id is included' do
      expect do
        patch '/admin/image_bulk_update',
              params: { image_ids: [image1.id, 0], camera_id: camera.id }
      end.not_to(change { image1.reload.camera_id })

      expect(response).to have_http_status(:not_found)
    end

    it 'assigns taken_at with a 1-minute offset per image in id order, with no camera/lens selected' do
      patch '/admin/image_bulk_update',
            params: { image_ids: [image1.id, image2.id], taken_at: '2024-01-01T10:00' }

      expect(response).to redirect_to(admin_images_path)
      expect(flash[:notice]).to include('2枚')

      ordered = [image1, image2].sort_by(&:id)
      base = Time.zone.parse('2024-01-01T10:00')
      ordered.each_with_index do |image, index|
        expect(image.reload.taken_at).to eq(base + index.minutes)
      end
    end

    it 'leaves taken_at untouched when the field is blank' do
      original_taken_at = image1.taken_at

      patch '/admin/image_bulk_update', params: { image_ids: [image1.id], camera_id: camera.id, taken_at: '' }

      expect(image1.reload.taken_at).to eq(original_taken_at)
    end
  end
end
