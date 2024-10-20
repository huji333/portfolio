class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.string :title, null: false
      t.string :caption, null: false
      t.datetime :taken_at, null: false
      t.references :camera, null: false, foreign_key: true
      t.references :lens, null: false, foreign_key: true
      t.integer :display_order, null: false
      t.boolean :is_published, null: false, default: true

      t.timestamps
    end
    add_index :images, :display_order
    add_index :images, :is_published
    add_index :images, :taken_at
  end
end
