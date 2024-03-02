class AddBucketTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :bucket_token, :string, unique: true
  end
end
