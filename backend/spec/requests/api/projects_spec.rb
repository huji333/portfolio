require 'rails_helper'

RSpec.describe 'Projects API', type: :request do
  before do
    create(:project, title: 'Test Project 1', id: 1)
    create(:project, title: 'Test Project 2', id: 2)
  end

  describe 'index' do
    it 'should return a list of projects' do
      get '/api/projects'
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.length).to eq(2)
    end
  end
end
