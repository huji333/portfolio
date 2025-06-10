require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  before do
    create(:category, name: 'Test Category 1', id: 1)
    create(:category, name: 'Test Category 2', id: 2)
  end

  context 'fetch categories' do
    it 'should return a list of categories' do
      get '/api/categories'
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.length).to eq(2)
    end
  end
end
