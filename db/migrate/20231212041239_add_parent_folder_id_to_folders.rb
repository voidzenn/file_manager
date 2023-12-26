class AddParentFolderIdToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :parent_folder_id, :integer, default: '', after: :user_id
  end
end
