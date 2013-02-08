module ApplicationHelper
  def image_info(url, user)
    require 'open-uri'
    
    doc = Nokogiri::HTML(open(url))
    img = doc.at_css("#prodImageCell img")[:src]
    return img
  end
  
  def name_info(url, user)
    require 'open-uri'
    
    doc = Nokogiri::HTML(open(url))
    name = doc.at_css("#btAsinTitle").text
    return price
  end
  
  def price_info(url, user)
    require 'open-uri'
    
    price = doc.at_css(".priceLarge").text[/[0-9\.]+/]

    return price
  end
  
end
