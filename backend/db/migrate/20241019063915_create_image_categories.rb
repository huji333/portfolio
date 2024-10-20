class CreateImageCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :image_categories do |t|
      t.references :image, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :image_categories, [:image_id, :category_id], unique: true
  end
end
