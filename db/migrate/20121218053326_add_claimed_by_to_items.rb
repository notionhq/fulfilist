class AddClaimedByToItems < ActiveRecord::Migration
  def change
    add_column :items, :claimed_by, :integer
    add_index :items, :claimed_by
  end
end
