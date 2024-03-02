class AddFullPathToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :full_path, :string
  end
end
