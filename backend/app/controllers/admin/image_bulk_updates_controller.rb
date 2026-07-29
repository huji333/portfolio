class Admin::ImageBulkUpdatesController < Admin::Base
  # 画像一覧のチェックボックス選択に対する一括メタデータ付与。空欄の項目は変更しない
  # （クリアは単体編集で行う）。カテゴリは既存への追加（union）。
  def update
    image_ids = Array(params[:image_ids]).compact_blank
    return redirect_to_images(alert: '画像が選択されていません。') if image_ids.empty?

    camera = find_gear(Camera, params[:camera_id])
    return redirect_to_images(alert: '指定されたカメラが見つかりません。') if stale_id?(params[:camera_id], camera)

    lens = find_gear(Lens, params[:lens_id])
    return redirect_to_images(alert: '指定されたレンズが見つかりません。') if stale_id?(params[:lens_id], lens)

    categories = Category.where(id: Array(params[:category_ids]).compact_blank).to_a
    taken_at_base = parse_taken_at_base
    return redirect_to_images(alert: '日時の形式が正しくありません。') if taken_at_base == :invalid
    return redirect_to_images(alert: '適用する項目が選択されていません。') if nothing_to_apply?(camera, lens, categories, taken_at_base)

    images = Image.bulk_assign!(image_ids, camera: camera, lens: lens, categories: categories,
                                           taken_at_base: taken_at_base)
    redirect_to_images(notice: "#{images.size}枚に一括適用しました。")
  end

  private

  def parse_taken_at_base
    return nil if params[:taken_at].blank?

    Time.zone.parse(params[:taken_at])
  rescue ArgumentError
    :invalid
  end

  def nothing_to_apply?(camera, lens, categories, taken_at_base)
    camera.nil? && lens.nil? && categories.empty? && taken_at_base.nil?
  end

  def find_gear(klass, id)
    klass.find_by(id: id) if id.present?
  end

  def stale_id?(id, record)
    id.present? && record.nil?
  end

  # 一括操作の戻り先。filter と page を引き継いで「絞ってから一括付与」のフローを維持する。
  def redirect_to_images(**flash_options)
    redirect_to admin_images_path(filter: params[:filter].presence, page: params[:page].presence), **flash_options
  end
end
