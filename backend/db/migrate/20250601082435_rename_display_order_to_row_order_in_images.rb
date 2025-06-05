class RenameDisplayOrderToRowOrderInImages < ActiveRecord::Migration[7.2]
  def change
    rename_column :images, :display_order, :row_order
    change_column_null :images, :row_order, true
    unless index_exists?(:images, :row_order)
      add_index :images, :row_order
    end
  end
end
