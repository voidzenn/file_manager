class AddUniqueTokenToFolders < ActiveRecord::Migration[7.0]
  def change
    add_column :folders, :unique_token, :string, null: false, after: :user_id
  end
end
