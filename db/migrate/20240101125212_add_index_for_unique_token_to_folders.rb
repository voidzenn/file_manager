class AddIndexForUniqueTokenToFolders < ActiveRecord::Migration[7.0]
  def change
    add_index :folders, :unique_token, unique: true
  end
end
