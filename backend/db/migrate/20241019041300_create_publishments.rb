class CreatePublishments < ActiveRecord::Migration[7.2]
  def change
    create_table :publishments do |t|
      t.references :article, null: false, foreign_key: true
      t.datetime :published_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_foreign_key :publishments, :articles
  end
end
