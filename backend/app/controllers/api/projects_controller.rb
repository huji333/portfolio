class Api::ProjectsController < ApplicationController
  def index
    projects = Project.order(created_at: :desc).with_attached_file
    render json: projects.map { |project| project_json(project) }
  end

  private

  def project_json(project)
    metadata = project.file.attached? ? project.file.metadata : {}
    width = (metadata['width'] || metadata[:width])&.to_i
    height = (metadata['height'] || metadata[:height])&.to_i

    project.as_json(only: %i[id title link]).merge(
      file: project.file_url,
      thumbnail: project.thumbnail_url,
      width: width,
      height: height
    )
  end
end
