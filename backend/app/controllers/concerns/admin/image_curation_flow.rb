# 一括取り込み後の逐次キュレーション（下書きを順に編集して公開していく）フローと、
# フォームの送信ボタン（下書き保存/公開/次へ）からの公開状態の導出。
module Admin::ImageCurationFlow
  extend ActiveSupport::Concern

  private

  # 押されたボタンから公開状態を導出する。
  # true = 公開 / false = 下書き / nil = 変更なし（公開中の画像の「保存」）
  def publish_intent
    return true if params[:commit_publish].present? || params[:publish_and_next].present?
    return false if params[:commit_draft].present?

    nil
  end

  def advance_to_next?
    params[:save_and_next].present? || params[:publish_and_next].present?
  end

  # 「次へ」ボタンの表示可否（編集中の画像以外に未編集の下書きが残っているか）
  def set_next_draft_flag
    @next_draft_exists = Image.uncurated.where.not(id: @image.id).exists?
  end

  def redirect_to_next_uncurated
    verb = @image.is_published? ? '公開しました' : '保存しました'
    remaining = Image.uncurated.where.not(id: @image.id)
    next_image = remaining.rank(:row_order).first
    return redirect_to admin_images_path, notice: "#{verb}。未編集の下書きはありません。" if next_image.nil?

    redirect_to edit_admin_image_path(next_image), notice: "#{verb}。残り#{remaining.count}枚の下書きがあります。"
  end
end
