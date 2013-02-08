class AddAttachmentProductImageToItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.attachment :product_image
    end
  end

  def self.down
    drop_attached_file :items, :product_image
  end
end
