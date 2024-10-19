class CreateCameras < ActiveRecord::Migration[7.2]
  def change
    create_table :cameras do |t|
      t.string :name, null: false
      t.string :manufacturer, null: false

      t.timestamps
    end
  end
end
