class Admin::ImageBulkUpdatesController < Admin::Base
  # 画像一覧のチェックボックス選択に対する一括メタデータ付与。空欄の項目は変更しない
  # （クリアは単体編集で行う）。カテゴリは既存への追加（union）。
  def update
    image_ids = Array(params[:image_ids]).compact_blank
    return redirect_to_images(alert: '画像が選択されていません。') if image_ids.empty?

    camera = Camera.find(params[:camera_id]) if params[:camera_id].present?
    lens = Lens.find(params[:lens_id]) if params[:lens_id].present?
    categories = Category.where(id: Array(params[:category_ids]).compact_blank).to_a
    return redirect_to_images(alert: '適用する項目が選択されていません。') if camera.nil? && lens.nil? && categories.empty?

    images = Image.bulk_assign!(image_ids, camera: camera, lens: lens, categories: categories)
    redirect_to_images(notice: "#{images.size}枚に一括適用しました。")
  end

  private

  # 一括操作の戻り先。filter と page を引き継いで「絞ってから一括付与」のフローを維持する。
  def redirect_to_images(**flash_options)
    redirect_to admin_images_path(filter: params[:filter].presence, page: params[:page].presence), **flash_options
  end
end
