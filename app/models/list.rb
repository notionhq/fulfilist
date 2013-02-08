class List < ActiveRecord::Base
  attr_accessible :name, :user_id, :comment
  
  has_many :items, dependent: :destroy
  belongs_to :user
  
  def images
    if items
      images = []
      items.each do |item|
        if item.product_image.url == "/product_images/original/missing.png"
          images << item.img_url
        else
          images << item.product_image.url(:medium)
        end
      end
      return images
    end
  end
end