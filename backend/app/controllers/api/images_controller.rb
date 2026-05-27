class Api::ImagesController < ApplicationController
  def index
    limit = (params[:limit]&.to_i || 20).clamp(1, 50)
    all_images = Image.for_gallery(
      category_ids: category_ids_param,
      cursor: params[:cursor],
      limit: limit
    ).to_a
    has_more = all_images.size > limit
    images = all_images.take(limit)

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
      params[:categories].split(',').filter_map { |id| (n = id.strip.to_i).positive? ? n : nil }
    else
      params[:categories]
    end
  end

  # カメラのidとレンズのidを名前に変更して渡す
  def image_json(image)
    width, height = file_dimensions(image.file)

    image.as_json(except: %i[camera_id lens_id]).merge(
      file: image.file_url,
      thumbnail: image.thumbnail_url,
      width: width,
      height: height,
      camera_name: "#{image.camera&.manufacturer} #{image.camera&.name}".strip,
      lens_name: image.lens&.name
    )
  end
end
