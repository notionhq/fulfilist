class AddMoreFacebookInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_url, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
