require 'rails_helper'

RSpec.describe 'Images API', type: :request do
  let(:cdn_base_url) { ENV.fetch('CLOUDFRONT_BASE_URL', nil) }
  let!(:category1) { create(:category, name: 'Test Category 1') }
  let!(:category2) { create(:category, name: 'Test Category 2') }

  before do
    create(:image, title: 'Test Image 1', taken_at: 1.day.ago)
    create(:image, title: 'Test Image 2', taken_at: 2.days.ago)
    create(:image, title: 'Test Image unpublished', is_published: false)
    create(:image, title: 'Test Image with category 1', taken_at: 3.days.ago, categories: [category1])
    create(:image, title: 'Test Image with category 2', taken_at: 4.days.ago, categories: [category2])
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
        get "/api/images?categories=#{category1.id},#{category2.id}"
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

      it 'allows thumbnail to be nil when not generated' do
        allow_any_instance_of(Image).to receive(:thumbnail_url).and_return(nil)

        get '/api/images'
        payload = response.parsed_body['images'].first

        expect(payload['thumbnail']).to be_nil
      end
    end

    context 'cursor pagination' do
      it 'fetches the next page using next_cursor' do
        get '/api/images', params: { limit: 2 }
        first_page = response.parsed_body
        expect(first_page['has_more']).to be true
        expect(first_page['next_cursor']).to be_present
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

      it 'clamps limit to 50 at the upper bound' do
        expect(Image).to receive(:for_gallery).with(hash_including(limit: 50)).and_call_original
        get '/api/images', params: { limit: 100 }

        expect(response).to have_http_status(:success)
      end

      it 'clamps limit to 1 at the lower bound' do
        get '/api/images', params: { limit: 0 }

        expect(response.parsed_body['images'].length).to eq(1)
      end
    end

    context 'featured pinning' do
      let!(:featured) { create(:image, :featured, title: 'Featured 1', featured_rank: 0, taken_at: 10.days.ago) }

      it 'round-trips a cursor across the featured -> timeline segment boundary' do
        get '/api/images', params: { limit: 1 }
        first_page = response.parsed_body

        expect(first_page['images'].pluck('title')).to eq(['Featured 1'])
        expect(first_page['next_cursor']).to match(/\Af,/)

        get '/api/images', params: { limit: 10, cursor: first_page['next_cursor'] }
        second_page = response.parsed_body

        expect(second_page['images'].pluck('title')).not_to include('Featured 1')
        expect(second_page['images'].length).to eq(4)
      end
    end
  end
end
