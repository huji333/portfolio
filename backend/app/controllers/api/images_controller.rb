class Api::ImagesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    if params[:categories].present?
      category_ids =
        if params[:categories].is_a?(String)
          params[:categories].split(',').map(&:strip)
        else
          params[:categories]
        end

      images = Image.joins(:categories).where(categories: { id: category_ids }).distinct
    else
      images = Image.all
    end
    render json: images.map { |image|
      image.as_json.merge(file: url_for(image.file))
    }
  end

  def show
    image = Image.find(params[:id])
    render json: image.as_json.merge(file: url_for(image.file))
  end
end
