class AddImgUrlToItems < ActiveRecord::Migration
  def change
    add_column :items, :img_url, :text
  end
end
