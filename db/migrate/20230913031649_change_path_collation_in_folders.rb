class ChangePathCollationInFolders < ActiveRecord::Migration[7.0]
  def change
    change_column :folders, :path, :string, collation: "en_US.utf8"
  end
end
