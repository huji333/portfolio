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
      next_cursor: has_more ? next_cursor(images.last) : nil,
      has_more: has_more
    }
  end

  private

  # 最後の要素の種別に応じて次ページの cursor を組み立てる。
  # featured なら featured セグメントの続き、時系列なら時系列セグメントの続き。
  # taken_at はエポックミリ秒に丸める（DB は microsecond 精度）。round だと切り上げで
  # 元の行の実精度より未来の境界になり得て、次ページの厳密不等号から自分自身が漏れて
  # 再出現する。floor で必ず自分自身の実精度以下に丸め、境界の取りこぼしを防ぐ。
  def next_cursor(image)
    if image.featured_rank.present?
      "f,#{image.featured_rank},#{image.id}"
    elsif image.taken_at
      "t,#{(image.taken_at.to_f * 1000).floor},#{image.id}"
    end
  end

  def category_ids_param
    case params[:categories]
    when String
      params[:categories].split(',').filter_map { |id| (n = id.strip.to_i).positive? ? n : nil }
    when Array
      params[:categories].filter_map { |id| (n = id.to_i).positive? ? n : nil }
    end
  end

  def image_json(image)
    width, height = file_dimensions(image.file)
    {
      id: image.id,
      title: image.title,
      caption: image.caption,
      taken_at: image.taken_at,
      file: image.display_url,
      thumbnail: image.thumbnail_url,
      width: width,
      height: height,
      camera_name: image.camera&.display_label,
      lens_name: image.lens&.name
    }
  end
end
