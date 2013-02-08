class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :url
      t.float :price
      t.string :store
      t.integer :user_id

      t.timestamps
    end
    add_index :items, :user_id
  end
end
