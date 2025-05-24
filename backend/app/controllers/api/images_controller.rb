class Api::ImagesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    category_ids =
      if params[:categories].is_a?(String)
        params[:categories].split(',').map(&:strip)
      else
        params[:categories]
      end

    images = Image.published.filter_by_categories(category_ids)
    render json: images.map { |image|
      image.as_json.merge(file: url_for(image.file))
    }
  end

  def show
    image = Image.find(params[:id])
    render json: image.as_json.merge(file: url_for(image.file))
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Image not found' }, status: :not_found
  end
end
