class Api::ImagesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    images = Image.with_attached_file.order(:display_order)
    render json: images.map { |image|
      image.as_json.merge(file: url_for(image.file))
    }
  end

  def show
    image = Image.find(params[:id])
    render json: image.as_json.merge(file: url_for(image.file))
  end
end
