require 'rails_helper'

RSpec.describe 'Camera Names API', type: :request do
  describe 'POST /api/camera_name' do
    context 'with valid parameters' do
      it 'should resolve camera name for exact match' do
        post '/api/camera_name', params: { make: 'SONY', model: 'ILCE-7CM2' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['manufacturer']).to eq('SONY')
        expect(response.parsed_body['camera_name']).to eq('a7C II')
      end

      it 'should resolve camera name for FUJIFILM' do
        post '/api/camera_name', params: { make: 'FUJIFILM', model: 'X-HF1' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['manufacturer']).to eq('FUJIFILM')
        expect(response.parsed_body['camera_name']).to eq('X half')
      end

      it 'should return original model name for unknown camera' do
        post '/api/camera_name', params: { make: 'CANON', model: 'EOS-R5' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['manufacturer']).to eq('CANON')
        expect(response.parsed_body['camera_name']).to eq('EOS-R5')
      end

      it 'should handle case insensitive input' do
        post '/api/camera_name', params: { make: 'sony', model: 'ilce-7cm2' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['manufacturer']).to eq('sony')
        expect(response.parsed_body['camera_name']).to eq('a7C II')
      end

      it 'should handle whitespace in parameters' do
        post '/api/camera_name', params: { make: '  SONY  ', model: '  ILCE-7CM2  ' }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['manufacturer']).to eq('SONY')
        expect(response.parsed_body['camera_name']).to eq('a7C II')
      end
    end

    context 'with invalid parameters' do
      it 'should return error when make is missing' do
        post '/api/camera_name', params: { model: 'ILCE-7CM2' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('make and model parameters are required')
      end

      it 'should return error when model is missing' do
        post '/api/camera_name', params: { make: 'SONY' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('make and model parameters are required')
      end

      it 'should return error when both parameters are missing' do
        post '/api/camera_name', params: {}

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('make and model parameters are required')
      end

      it 'should return error when make is blank' do
        post '/api/camera_name', params: { make: '', model: 'ILCE-7CM2' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('make and model parameters are required')
      end

      it 'should return error when model is blank' do
        post '/api/camera_name', params: { make: 'SONY', model: '' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('make and model parameters are required')
      end
    end
  end
end
