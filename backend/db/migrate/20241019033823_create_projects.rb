class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.string :link, null: false

      t.timestamps
    end
  end
end
