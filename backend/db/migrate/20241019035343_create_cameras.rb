class CreateCameras < ActiveRecord::Migration[7.2]
  def change
    create_table :cameras do |t|
      t.string :name
      t.string :manufacturer

      t.timestamps
    end
  end
end
