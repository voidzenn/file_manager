class AddFullPathToFileUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :file_uploads, :full_path, :string
  end
end
