require 'rails_helper'

RSpec.describe 'Admin access control', type: :request do
  include Devise::Test::IntegrationHelpers

  describe 'GET /admin as a guest user' do
    before { sign_in create(:user, role: 'guest') }

    it 'returns 401 with the unauthorized message for HTML requests' do
      get '/admin'

      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('You are not authorized to perform this action.')
    end

    it 'returns 401 JSON for JSON requests' do
      get '/admin', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('You are not authorized to perform this action.')
    end
  end

  describe 'GET /admin as an unauthenticated user' do
    it 'redirects to the sign in page' do
      get '/admin'

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
