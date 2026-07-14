class AddFeaturedRankReplaceRowOrderInImages < ActiveRecord::Migration[8.1]
  # 画像並び順の設計見直し（#273）。公開ギャラリーの基本順は taken_at 由来に、
  # 手動キュレーションは featured_rank 1本に一本化する。row_order / ranked-model は廃止。
  def change
    add_column :images, :featured_rank, :integer
    add_index :images, :featured_rank, where: "featured_rank IS NOT NULL"
    add_index :images, %i[taken_at id]

    remove_index :images, :row_order
    remove_index :images, :taken_at
    remove_column :images, :row_order, :integer
  end
end
