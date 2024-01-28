class AddCaseSensitiveToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :email, :string, collation: "en_US.utf8"
  end
end
