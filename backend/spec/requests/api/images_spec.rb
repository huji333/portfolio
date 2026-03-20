require 'rails_helper'

RSpec.describe 'Images API', type: :request do
  let(:cdn_base_url) { ENV.fetch('CLOUDFRONT_BASE_URL', nil) }

  before do
    create(:image, title: 'Test Image 1', id: 1, row_order: 0)
    create(:image, title: 'Test Image 2', row_order: 1)
    create(:image, title: 'Test Image unpublished', is_published: false)
    create(:image, title: 'Test Image with category 1', row_order: 2,
                   categories: [create(:category, name: 'Test Category 1', id: 1)])
    create(:image, title: 'Test Image with category 2', row_order: 3,
                   categories: [create(:category, name: 'Test Category 2', id: 2)])
  end

  describe 'index' do
    context 'fetch all images' do
      it 'should return a list of published images' do
        get '/api/images'
        expect(response).to have_http_status(:success)
        body = response.parsed_body
        expect(body['images'].length).to eq(4)
        expect(body).to have_key('next_cursor')
        expect(body).to have_key('has_more')
      end
    end

    context 'fetch images by category' do
      it 'should return a list of images by category' do
        get "/api/images?categories=1,2"
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['images'].length).to eq(2)
      end
    end

    context 'response payload' do
      it 'includes CDN-backed file URLs' do
        get '/api/images'
        payload = response.parsed_body['images'].first

        expect(payload['file']).to start_with(cdn_base_url)
      end

      it 'surfaces thumbnail URLs when available' do
        allow_any_instance_of(Image).to receive(:thumbnail_url).and_return("#{cdn_base_url}/thumbnails/custom-key")

        get '/api/images'
        payload = response.parsed_body['images'].first

        expect(payload['thumbnail']).to eq("#{cdn_base_url}/thumbnails/custom-key")
      end

      it 'allows thumbnail to be nil when not generated' do
        allow_any_instance_of(Image).to receive(:thumbnail_url).and_return(nil)

        get '/api/images'
        payload = response.parsed_body['images'].first

        expect(payload['thumbnail']).to be_nil
      end
    end

    context 'cursor pagination' do
      it 'returns has_more: false when all results fit within limit' do
        get '/api/images', params: { limit: 10 }
        body = response.parsed_body

        expect(body['images'].length).to eq(4)
        expect(body['has_more']).to be false
        expect(body['next_cursor']).to be_nil
      end

      it 'returns has_more: true and next_cursor when there are more results' do
        get '/api/images', params: { limit: 2 }
        body = response.parsed_body

        expect(body['images'].length).to eq(2)
        expect(body['has_more']).to be true
        expect(body['next_cursor']).to be_present
      end

      it 'fetches the next page using next_cursor' do
        get '/api/images', params: { limit: 2 }
        first_page = response.parsed_body
        first_page_titles = first_page['images'].pluck('title')

        get '/api/images', params: { limit: 2, cursor: first_page['next_cursor'] }
        second_page = response.parsed_body
        second_page_titles = second_page['images'].pluck('title')

        expect(second_page['images'].length).to eq(2)
        expect(second_page['has_more']).to be false
        expect(second_page['next_cursor']).to be_nil

        # No overlap between pages
        expect(first_page_titles & second_page_titles).to be_empty
      end

      it 'returns images ordered by row_order and id' do
        get '/api/images'
        titles = response.parsed_body['images'].pluck('title')

        expect(titles).to eq(['Test Image 1', 'Test Image 2', 'Test Image with category 1',
                              'Test Image with category 2'])
      end

      it 'caps limit at 50' do
        get '/api/images', params: { limit: 100 }
        body = response.parsed_body

        # Should not error; limit is capped internally
        expect(response).to have_http_status(:success)
        expect(body['images'].length).to eq(4)
      end

      it 'applies cursor with category filter' do
        # Create extra images for the same category so we can paginate
        cat = Category.find(1)
        create(:image, title: 'Cat1 Extra 1', row_order: 4, categories: [cat])
        create(:image, title: 'Cat1 Extra 2', row_order: 5, categories: [cat])

        get '/api/images', params: { categories: '1', limit: 1 }
        first_page = response.parsed_body

        expect(first_page['images'].length).to eq(1)
        expect(first_page['has_more']).to be true

        get '/api/images', params: { categories: '1', limit: 10, cursor: first_page['next_cursor'] }
        second_page = response.parsed_body

        expect(second_page['images'].length).to eq(2)
        expect(second_page['has_more']).to be false
      end
    end
  end
end
