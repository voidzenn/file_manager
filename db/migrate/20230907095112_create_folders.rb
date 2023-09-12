class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders do |t|
      t.references :user, foreign_key: true, null: false
      t.string :path, null: false

      t.timestamps
    end
  end
end
