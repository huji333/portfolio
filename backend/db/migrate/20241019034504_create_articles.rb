class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.integer :status, null: false, default: 0 # 0: draft, 1: published, 2: archived

      t.timestamps
    end
  end
end
