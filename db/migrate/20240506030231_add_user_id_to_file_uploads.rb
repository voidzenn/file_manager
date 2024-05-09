class AddUserIdToFileUploads < ActiveRecord::Migration[7.0]
  def up
    add_reference :file_uploads, :user, index: true, foreign_key: true
  end

  def down
    remove_reference :file_uploads, :user
  end
end
