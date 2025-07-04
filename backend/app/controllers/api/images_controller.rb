class Api::ImagesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    category_ids =
      if params[:categories].is_a?(String)
        params[:categories].split(',').map(&:strip)
      else
        params[:categories]
      end

    images = Image.published.filter_by_categories(category_ids).includes(:camera, :lens)
    render json: images.map { |image| image_json(image) }
  end

  def show
    image = Image.includes(:camera, :lens).find(params[:id])
    render json: image_json(image)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Image not found' }, status: :not_found
  end

  private

  # カメラのidとレンズのidを名前に変更して渡す
  def image_json(image)
    image.as_json(except: [:camera_id, :lens_id]).merge(
      file: url_for(image.file),
      camera_name: "#{image.camera.manufacturer} #{image.camera.name}",
      lens_name: image.lens.name
    )
  end
end
