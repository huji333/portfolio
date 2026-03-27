class Api::ImagesController < ApplicationController
  def index
    limit = [(params[:limit] || 20).to_i, 50].min
    images = Image.for_gallery(
      category_ids: category_ids_param,
      cursor: params[:cursor],
      limit: limit
    )
    has_more = images.size > limit
    images = images.first(limit)

    render json: {
      images: images.map { |image| image_json(image) },
      next_cursor: has_more ? "#{images.last.row_order},#{images.last.id}" : nil,
      has_more: has_more
    }
  end

  private

  def category_ids_param
    case params[:categories]
    when String
      params[:categories].split(',').map { |id| id.strip.to_i }
    else
      params[:categories]
    end
  end

  # カメラのidとレンズのidを名前に変更して渡す
  def image_json(image)
    metadata = image.file.attached? ? image.file.metadata : {}
    width = metadata['width']&.to_i
    height = metadata['height']&.to_i

    image.as_json(except: %i[camera_id lens_id]).merge(
      file: image.file_url,
      thumbnail: image.thumbnail_url,
      width: width,
      height: height,
      camera_name: "#{image.camera.manufacturer} #{image.camera.name}",
      lens_name: image.lens&.name
    )
  end
end
