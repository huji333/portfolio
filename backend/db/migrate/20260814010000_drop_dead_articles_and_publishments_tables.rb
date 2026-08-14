# 2024-10 に作られたまま一度も使われなかったブログ機能のテーブルを削除する。
# モデル・コントローラ・ルート・seed・spec のいずれからも参照がないことを確認済み。
# drop_table にブロックを渡しているので down でスキーマは復元できる（データは戻らない）。
class DropDeadArticlesAndPublishmentsTables < ActiveRecord::Migration[8.1]
  def change
    # 子テーブルを先に落とす（外部キー制約も一緒に消える）
    drop_table :publishments do |t|
      t.references :article, null: false, foreign_key: true
      t.datetime :published_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end

    drop_table :articles do |t|
      t.text :content, null: false
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
