class AddUniqueTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unique_token, :string, null: false, after: :id
  end
end
