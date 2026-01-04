class Api::ImagesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    images = Image.for_gallery(category_ids: category_ids_param)
    render json: images.map { |image| image_json(image) }
  end

  private

  def category_ids_param
    case params[:categories]
    when String
      params[:categories].split(',').map(&:strip)
    else
      params[:categories]
    end
  end

  # カメラのidとレンズのidを名前に変更して渡す
  def image_json(image)
    metadata = image.file.attached? ? image.file.metadata : {}
    width = metadata['width']&.to_i
    height = metadata['height']&.to_i

    image.as_json(except: [:camera_id, :lens_id]).merge(
      file: image.file_url,
      thumbnail: image.thumbnail_url,
      width: width,
      height: height,
      camera_name: "#{image.camera.manufacturer} #{image.camera.name}",
      lens_name: image.lens&.name
    )
  end
end
