class AddParentChildToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :parent_id, :integer
    add_column :folders, :child_id, :integer
  end
end
