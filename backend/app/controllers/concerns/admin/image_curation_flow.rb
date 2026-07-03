# 画像編集カードのフロー。送信ボタン（保存 / 公開する / 非公開に戻す / ← →）から
# 公開状態と保存後の遷移先を導出する。←/→ は保存してから隣のカードへ移動する。
module Admin::ImageCurationFlow
  extend ActiveSupport::Concern

  private

  # 押されたボタンから公開状態を導出する。
  # true = 公開 / false = 下書きへ戻す / nil = 変更なし
  def publish_intent
    return true if params[:commit_publish].present?
    return false if params[:commit_draft].present?

    nil
  end

  # 表示順で隣り合う画像（編集カードの ←/→ の行き先と disabled 判定）
  def set_adjacent_images
    @images_total = Image.count
    @prev_image = Image.rank(:row_order).where(row_order: ...@image.row_order).last
    @next_image = Image.rank(:row_order).where(row_order: (@image.row_order + 1)..).first
  end

  def after_save_edit_path
    target = if params[:nav_prev].present?
               @prev_image
             elsif params[:nav_next].present?
               @next_image
             end
    edit_admin_image_path(target || @image)
  end

  def update_notice
    case publish_intent
    when true then '公開しました。'
    when false then '非公開にしました。'
    else '保存しました。'
    end
  end
end
