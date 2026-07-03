class AddDescriptionAndTagsToProjects < ActiveRecord::Migration[8.1]
  def change
    change_table :projects, bulk: true do |t|
      t.text :description
      t.string :tags, array: true, default: [], null: false
    end
  end
end
