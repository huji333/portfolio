require 'rails_helper'

RSpec.describe 'Images API', type: :request do
  before do
    create(:image, title: 'Test Image 1', id: 1)
    create(:image, title: 'Test Image 2')
    create(:image, title: 'Test Image unpublished', is_published: false)
    create(:image, title: 'Test Image with category 1', categories: [create(:category, name: 'Test Category 1', id: 1)])
    create(:image, title: 'Test Image with category 2', categories: [create(:category, name: 'Test Category 2', id: 2)])
  end

  describe 'index' do
    context 'fetch all images' do
      it 'should return a list of published images' do
        get '/api/images'
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.length).to eq(4)
      end
    end

    context 'fetch images by category' do
      it 'should return a list of images by category' do
        get "/api/images?categories=1,2"
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.length).to eq(2)
      end
    end
  end

  describe 'show' do
    context 'fetch image by id' do
      it 'should return a image' do
        get "/api/images/1"
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(1)
        expect(response.parsed_body['title']).to eq('Test Image 1')
      end
    end
    context 'return error if image not found' do
      it 'should return error' do
        get "/api/images/999"
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Image not found')
      end
    end
  end
end
