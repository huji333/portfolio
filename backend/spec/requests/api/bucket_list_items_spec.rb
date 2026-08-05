require 'rails_helper'

RSpec.describe 'BucketListItems API', type: :request do
  describe 'GET /api/bucket_list_items' do
    let!(:second_item) { create(:bucket_list_item, title: 'Second', position: 2) }
    let!(:first_item) { create(:bucket_list_item, title: 'First', position: 1, done: true) }

    before { create(:bucket_list_item, title: 'Hidden', published: false) }

    it 'returns published items ordered by position' do
      get '/api/bucket_list_items'
      expect(response).to have_http_status(:success)

      items = response.parsed_body
      expect(items.pluck('title')).to eq(%w[First Second])
      expect(items.first).to include('done' => true, 'likes_count' => 0, 'liked' => false)
    end

    it 'marks items liked by the given device' do
      create(:bucket_list_like, bucket_list_item: first_item, device_uuid: 'device-1')
      create(:bucket_list_like, bucket_list_item: second_item, device_uuid: 'other-device')

      get '/api/bucket_list_items', params: { device_uuid: 'device-1' }

      liked_flags = response.parsed_body.to_h { |item| [item['title'], item['liked']] }
      expect(liked_flags).to eq('First' => true, 'Second' => false)
    end
  end

  describe 'POST /api/bucket_list_items/:bucket_list_item_id/like' do
    let!(:item) { create(:bucket_list_item) }

    it 'adds at most one like per device' do
      expect do
        2.times { post "/api/bucket_list_items/#{item.id}/like", params: { device_uuid: 'device-1' } }
      end.to change { item.reload.likes_count }.by(1)

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include('likes_count' => 1, 'liked' => true)
    end

    it 'rejects a blank device_uuid' do
      post "/api/bucket_list_items/#{item.id}/like"
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns 404 for an unpublished item' do
      hidden = create(:bucket_list_item, published: false)
      post "/api/bucket_list_items/#{hidden.id}/like", params: { device_uuid: 'device-1' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/bucket_list_items/:bucket_list_item_id/like' do
    let!(:item) { create(:bucket_list_item) }

    it 'removes the like of the device' do
      create(:bucket_list_like, bucket_list_item: item, device_uuid: 'device-1')

      delete "/api/bucket_list_items/#{item.id}/like", params: { device_uuid: 'device-1' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include('likes_count' => 0, 'liked' => false)
      expect(item.reload.likes_count).to eq(0)
    end

    it 'is a no-op when the device has not liked' do
      delete "/api/bucket_list_items/#{item.id}/like", params: { device_uuid: 'device-1' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to include('likes_count' => 0, 'liked' => false)
    end
  end
end
