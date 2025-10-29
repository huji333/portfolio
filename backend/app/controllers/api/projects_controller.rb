class Api::ProjectsController < ApplicationController
  def index
    projects = Project.order(created_at: :desc).with_attached_file
    render json: projects.map { |project| project_json(project) }
  end

  private

  def project_json(project)
    project.as_json(only: %i[id title link]).merge(file: project.file_url)
  end
end
