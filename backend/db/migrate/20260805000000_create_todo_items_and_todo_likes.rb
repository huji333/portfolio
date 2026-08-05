# 学生生活やりたいことリスト（公開ページ /todo + admin 管理）。
# likes_count は todo_likes からの導出値だが、一覧表示のたびに COUNT しないよう
# Rails 標準 counter_cache で materialize する。
class CreateTodoItemsAndTodoLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :todo_items do |t|
      t.string :title, null: false
      t.text :note
      t.integer :position, null: false, default: 0
      t.boolean :done, null: false, default: false
      t.boolean :published, null: false, default: true
      t.integer :likes_count, null: false, default: 0
      t.timestamps
    end

    create_table :todo_likes do |t|
      # 単独 index は複合 unique index の左端 prefix で代替できるため張らない
      t.references :todo_item, null: false, foreign_key: true, index: false
      t.string :device_uuid, null: false
      t.timestamps
    end
    # 「1デバイス1いいね」をサーバ側で担保する本体
    add_index :todo_likes, %i[todo_item_id device_uuid], unique: true
  end
end
