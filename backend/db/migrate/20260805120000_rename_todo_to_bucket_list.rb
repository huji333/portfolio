# ドメイン用語の変更（todo は誤解を招くため bucket_list へ）。データは保持する
class RenameTodoToBucketList < ActiveRecord::Migration[8.1]
  def change
    rename_table :todo_items, :bucket_list_items
    rename_table :todo_likes, :bucket_list_likes
    rename_column :bucket_list_likes, :todo_item_id, :bucket_list_item_id
  end
end
