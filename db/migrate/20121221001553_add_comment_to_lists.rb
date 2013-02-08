class AddCommentToLists < ActiveRecord::Migration
  def change
    add_column :lists, :comment, :text
  end
end
