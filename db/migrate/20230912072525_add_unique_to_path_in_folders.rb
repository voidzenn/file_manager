class AddUniqueToPathInFolders < ActiveRecord::Migration[7.0]
  def change
    add_index :folders, [:path, :user_id], unique: true
  end
end
