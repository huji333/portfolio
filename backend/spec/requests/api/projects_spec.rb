require 'rails_helper'

RSpec.describe 'Projects API', type: :request do
  let!(:project_one) do
    create(:project, title: 'Test Project 1', id: 1, link: 'https://example.com/project-1')
  end
  let!(:project_two) do
    create(:project, title: 'Test Project 2', id: 2, link: 'https://example.com/project-2')
  end

  describe 'index' do
    it 'should return a list of projects' do
      get '/api/projects'
      expect(response).to have_http_status(:success)

      projects = response.parsed_body
      expect(projects.length).to eq(2)

      titles = projects.pluck('title')
      expect(titles).to match_array([project_one.title, project_two.title])

      links = projects.pluck('link')
      expect(links).to include(project_one.link, project_two.link)
    end
  end
end
