class CreateFileUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :file_uploads do |t|
      t.references :folder, foreign_key: true
      t.string :name
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
