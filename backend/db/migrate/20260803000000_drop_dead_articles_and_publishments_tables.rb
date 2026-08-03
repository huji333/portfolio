class DropDeadArticlesAndPublishmentsTables < ActiveRecord::Migration[8.0]
  def up
    # These tables were created in Oct 2024 for a blog/article feature that was
    # never implemented. No models, controllers, routes, or application code
    # references them. Drop the FK before the parent table.
    remove_foreign_key :publishments, :articles
    drop_table :publishments
    drop_table :articles
  end

  def down
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.timestamps
    end

    create_table :publishments do |t|
      t.references :article, null: false, foreign_key: true
      t.timestamps
    end
  end
end
