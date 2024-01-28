class ChangePathCollationInFolders < ActiveRecord::Migration[7.0]
  def change
    change_column :folders, :path, :string, collation: "utf8mb4_bin"
  end
end
