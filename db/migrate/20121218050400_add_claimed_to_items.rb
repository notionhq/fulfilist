class AddClaimedToItems < ActiveRecord::Migration
  def change
    add_column :items, :claimed, :boolean
  end
end
