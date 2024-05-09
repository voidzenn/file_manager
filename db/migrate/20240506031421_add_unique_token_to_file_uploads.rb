class AddUniqueTokenToFileUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :file_uploads, :unique_token, :string, null: false
    add_index :file_uploads, :unique_token, unique: true
  end
end
