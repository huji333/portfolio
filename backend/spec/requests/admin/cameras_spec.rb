require 'rails_helper'

RSpec.describe 'Admin::Cameras', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  before do
    sign_in user
    create(:camera, name: 'a7C II', manufacturer: 'SONY', id: 1)
    create(:camera, name: 'EOS R5', manufacturer: 'CANON', id: 2)
  end

  describe 'GET /admin/cameras/lookup' do
    context 'with valid parameters' do
      it 'should find camera by camera name' do
        get '/admin/cameras/lookup', params: { camera_name: 'a7C II' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(1)
        expect(response.parsed_body['name']).to eq('a7C II')
        expect(response.parsed_body['manufacturer']).to eq('SONY')
      end

      it 'should find camera by manufacturer' do
        get '/admin/cameras/lookup', params: { manufacturer: 'CANON' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(2)
        expect(response.parsed_body['name']).to eq('EOS R5')
        expect(response.parsed_body['manufacturer']).to eq('CANON')
      end

      it 'should find camera by both camera name and manufacturer' do
        get '/admin/cameras/lookup', params: { camera_name: 'a7C II', manufacturer: 'SONY' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['id']).to eq(1)
        expect(response.parsed_body['name']).to eq('a7C II')
        expect(response.parsed_body['manufacturer']).to eq('SONY')
      end
    end

    context 'with invalid parameters' do
      it 'should return error when camera not found' do
        get '/admin/cameras/lookup', params: { camera_name: 'Unknown Camera' }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Camera not found')
      end

      it 'should return error when no parameters provided' do
        get '/admin/cameras/lookup'

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Camera name or manufacturer parameter is required')
      end

      it 'should return error when both parameters are blank' do
        get '/admin/cameras/lookup', params: { camera_name: '', manufacturer: '' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Camera name or manufacturer parameter is required')
      end
    end
  end
end
