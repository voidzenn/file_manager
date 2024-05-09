class AddIndexForUniqueTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :unique_token, unique: truez
  end
end
