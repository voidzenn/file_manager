class AddCaseSensitiveToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :email, :string, collation: "utf8mb4_unicode_ci"
  end
end
