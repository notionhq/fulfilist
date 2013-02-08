class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
    add_index :lists, :user_id
  end
end
