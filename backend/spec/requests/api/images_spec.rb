require 'rails_helper'

RSpec.describe 'Images API', type: :request do
  let(:cdn_base_url) { ENV.fetch('CLOUDFRONT_BASE_URL', nil) }

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

    context 'response payload' do
      it 'includes CDN-backed file URLs' do
        get '/api/images'
        payload = response.parsed_body.first

        expect(payload['file']).to start_with(cdn_base_url)
      end

      it 'surfaces thumbnail URLs when available' do
        allow_any_instance_of(Image).to receive(:thumbnail_url).and_return("#{cdn_base_url}/thumbnails/custom-key")

        get '/api/images'
        payload = response.parsed_body.first

        expect(payload['thumbnail']).to eq("#{cdn_base_url}/thumbnails/custom-key")
      end

      it 'allows thumbnail to be nil when not generated' do
        allow_any_instance_of(Image).to receive(:thumbnail_url).and_return(nil)

        get '/api/images'
        payload = response.parsed_body.first

        expect(payload['thumbnail']).to be_nil
      end
    end
  end
end
