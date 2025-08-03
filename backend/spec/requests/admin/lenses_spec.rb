require 'rails_helper'

RSpec.describe 'Admin::Lenses', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before do
    sign_in user
    create(:lens, name: 'FE 24-70mm f/2.8 GM', id: 1)
    create(:lens, name: 'FE 70-200mm f/2.8 GM', id: 2)
    create(:lens, name: 'RF 24-70mm f/2.8L IS USM', id: 3)
  end

  describe 'GET /admin/lenses/lookup' do
    context 'with valid parameters' do
      it 'should find lens by exact name' do
        get '/admin/lenses/lookup', params: { name: 'FE 24-70mm f/2.8 GM' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(1)
        expect(response.parsed_body['name']).to eq('FE 24-70mm f/2.8 GM')
      end

      it 'should find lens by partial name match' do
        get '/admin/lenses/lookup', params: { name: '24-70mm' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(1)
        expect(response.parsed_body['name']).to eq('FE 24-70mm f/2.8 GM')
      end

      it 'should find lens by case insensitive search' do
        get '/admin/lenses/lookup', params: { name: 'fe 70-200mm' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(2)
        expect(response.parsed_body['name']).to eq('FE 70-200mm f/2.8 GM')
      end

      it 'should find lens by manufacturer prefix' do
        get '/admin/lenses/lookup', params: { name: 'RF' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(3)
        expect(response.parsed_body['name']).to eq('RF 24-70mm f/2.8L IS USM')
      end
    end

    context 'with invalid parameters' do
      it 'should return error when lens not found' do
        get '/admin/lenses/lookup', params: { name: 'Unknown Lens' }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Lens not found')
      end

      it 'should return error when no name parameter provided' do
        get '/admin/lenses/lookup'

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Name parameter is required')
      end

      it 'should return error when name parameter is blank' do
        get '/admin/lenses/lookup', params: { name: '' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Name parameter is required')
      end
    end
  end
end
