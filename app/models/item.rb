class Item < ActiveRecord::Base
  attr_accessible :name, :price, :store, :url, :user_id, :img_url, :claimed, :claimed_by, :list_id, :comment, :product_image
  
  has_attached_file :product_image, :styles => { 
    :medium => ["150x150>", :jpg]
    },
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :bucket => "wishlist_#{Rails.env}",
    :url => "/items/:id/:style/:basename.:extension",
    :path => "/items/:id/:style/:filename"
    
  validates_attachment_content_type :product_image, :content_type => [ 'image/gif', 'image/png', 'image/jpg', 'image/jpeg']
  validates_attachment_size :product_image, :less_than => 5.megabytes
  
  belongs_to :list
  
  scope :available, where("claimed is not true")
  scope :claimed, where("claimed is true")
  
  after_update :check_info
  
  def fetch_info(url)
    require 'open-uri'
    doc = Nokogiri::HTML(open(url))
    store = parse_url(url)
    
    # name = check_meta_name(doc)
    # image = check_meta_image(doc)
    
    # Amazon Specific info
    if store == "Amazon"
      if doc.at_css("#btAsinTitle")
        name = doc.at_css("#btAsinTitle").text
      elsif doc.at_css("h1#title")
        name = doc.at_css("h1#title").text
      else
        name = "unknown"
      end
      
      if doc.at_css(".priceLarge")
        price = doc.at_css(".priceLarge").text[/\d+(\.\d{1,2})?/]
      elsif doc.at_css(".a-color-price")
        price = doc.at_css(".a-color-price").text[/\d+(\.\d{1,2})?/]
      else
        price = "unknown"
      end
      
      if doc.at_css("#prodImageCell img")
        image = doc.at_css("#prodImageCell img")[:src]
      elsif doc.at_css("#main-image")
        image = doc.at_css("#main-image")[:src]
      elsif doc.at_css(".kib-image-ma")
        image = doc.at_css(".kib-image-ma")[:src]
      else
        image = nil
      end
    
    # Walmart Specific info
    elsif store == "Walmart"
      name = doc.at_css(".productTitle").text
      price = doc.at_css(".camelPrice").text
      imgage = doc.at_css(".LargeItemPhoto215 a")[:href]
    
    # Bestbuy Specific info
    elsif store == "Bestbuy"
      name = doc.at_css("#sku-title").text
      price = doc.at_css(".item-price").text
      image = doc.at_css(".image-gallery-main-slide a img")[:src]
    
    # Apple Specific info
    elsif store == "Apple"
      
      if doc.at_css(".heading.heading-hero h1.title")
        name = doc.at_css(".heading.heading-hero h1.title").text.strip
        name = name.gsub("Configure your ", '')
      elsif doc.at_css(".header h1")
        name = doc.at_css(".header h1").text.strip
        name = name.gsub("Select an ", '')
      elsif doc.at_css(".header h2")
        name = doc.at_css(".header h2").text.strip
        name = name.gsub("Select an ", '')
      end
      
      if doc.at_css("#purchase-info-primary .value")
        price = doc.at_css("#purchase-info-primary .value").text
      elsif doc.at_css(".option-1")
        price = doc.at_css(".option-1 .price nobr").text
      end
      
      if doc.at_css(".hero-img")
        image = doc.at_css(".hero-img")[:src]
      elsif doc.at_css("img.hero")
        image = doc.at_css("img.hero")[:src]
      end
      
    # Sears Specific info
    elsif store == "Sears"
      name = doc.at_css(".productName h1").text
      price = doc.at_css(".youPay .pricing").text
      image = doc.at_css("#productMainImage img")[:src]
    
    # Nordstrom Specific info
    elsif store == "Nordstrom"
      name = doc.at_css(".rightcol h1").text
      price = doc.at_css("span.price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css(".fashion-photo-wrapper img")[:src]
    
    # Macys Specific info
    elsif store == "Macys"
      name = doc.at_css("#productTitle").text
      price = doc.at_css(".standardProdPricingGroup span:last").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#mainImage")[:src]
    
    # Etsy Specific info
    elsif store == "Etsy"
      name = doc.at_css("#item-title h1").text
      price = doc.at_css(".secondary .item-amount .currency-value").text[/^[\d]+\.[\d]{0,2}/]
      image = doc.at_css("#fullimage_link1 img")[:src]
    
    # REI Specific info
    elsif store == "REI"
      name = doc.at_css("#product h1").text
      price = doc.at_css(".price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#featuredImg")[:src]
      image = "http://www.rei.com" + image
    
    # The Gap Specific info, returns mostly unknown because of site's construction
    elsif store == "Gap"
      if doc.at_css("#productNameText")
        name = doc.at_css("#productNameText h1").text.strip
      else
        name = doc.at_css("title").text
      end
      if doc.at_css("#priceText")
        price = doc.at_css("#priceText").text
      else
        price = "unknown"
      end
      image = nil
    
    # J. Crew Specific info
    elsif store == "J. Crew"
      name = doc.at_css("h1").text
      price = doc.at_css(".price-single").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#mainImg")[:src]
    
    # Banana Republic Specific info
    elsif store == "Banana Republic"
      if doc.at_css("#productNameText")
        name = doc.at_css("#productNameText h1").text.strip
      else
        name = doc.at_css("title").text
      end
      if doc.at_css("#priceText")
        price = doc.at_css("#priceText").text
      else
        price = "unknown"
      end
      image = nil
    
    # Bed Bath and Beyond Specific info
    elsif store == "Bed Bath and Beyond"
      name = doc.at_css(".producttitle").text
      price = doc.at_css("tr:nth-child(4) td:nth-child(6)").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css(".ppprodimageline:nth-child(2) img")[:src]
      image = "http://www.bedbathandbeyond.com" + image
    
    # Everlane Specific info
    elsif store == "Everlane"
      name = String.new(doc.at_css("title").text.strip)
      name = name.gsub(" - Everlane", "")
      name = name.parameterize
      name = name.gsub(/na-s/, "n's")
      name = name.gsub("-", " ")
      name = name.titleize
      price = doc.at_css("#prices-container").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#primary-image")[:src]
    
    # Warby Parker Specific info
    elsif store == "Warby Parker"
      if doc.at_css(".productName")
        name = doc.at_css(".productName h1").text
      else
        name = doc.at_css(".product-name h1").text
      end
      price = doc.at_css(".price").text[/\d+(\.\d{1,2})?/]
      if doc.at_css(".framePic")
        image = doc.at_css(".framePic img")[:src]
      else
        image = doc.at_css(".toggle img")[:src]
      end
    
    # Target Specific info
    elsif store == "Target"
      name = doc.at_css(".product-name").text.strip
      price = doc.at_css(".offerPrice").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#heroImage")[:src]
    
    # Williams and Sonoma Specific info
    elsif store == "Williams and Sonoma"
      name = doc.at_css("h1").text
      price = doc.at_css(".price-amount").text
      image = doc.at_css("#hero")[:src]
      
    # Uncrate Specific info
    elsif store == "Uncrate"
      name = doc.at_css("h1 a").text
      price = doc.at_css(".abide").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("img.xl")[:src]
    
    elsif store == "Kickstarter"
      name = doc.at_css("#title").text
      price = "various"
      image = doc.at_css("img")[:src]
    
    elsif store == "Newegg"
      name = doc.at_css("h1 span").text.strip
      price = "unknown"
      image = doc.at_css(".mainSlide img")[:src]
    
    elsif store == "Pier 1"
      name = doc.at_css(".product-name").text.strip
      price = doc.at_css(".price-standard").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css(".primary-image")[:src]
      
    elsif store == "Pottery Barn"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".price-amount").text
      image = doc.at_css("#hero")[:src]
      
    elsif store == "Crate & Barrel"
      name = doc.at_css("#_productTitle").text.strip
      price = doc.at_css(".regPrice").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#_imgLarge")[:src]
    
    elsif store == "kmart"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".pricing").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#productMainImage img")[:src]
    
    elsif store == "jcp"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".gallery_page_price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_xpath("//meta[@property='og:image']/@content").value
      image = "http:" + image
    
    elsif store == "Costco"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".product-price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#large_images img")[:src]
    
    elsif store == "World Market"
      name = doc.at_css(".detailheader").text.strip
      price = doc.at_css(".singlePrice").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#mainimage")[:src]
    
    elsif store == "Sierra Trading Post"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".salePrice").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#largeImage")[:src]
      
    elsif store == "Eddie Bauer"
      name = doc.at_css("h1.title").text.strip
      price = doc.at_css(".priceWrap").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css(".mainImage img")[:src]
    
    elsif store == "L.L. Bean"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".toOrderItemPrice").text[/\d+(\.\d{1,2})?/]
      image = doc.at_xpath("//meta[@property='og:image']/@content").value
    
    elsif store == "Powell's"
      name = doc.at_css(".book-title").text.strip
      price = doc.at_css(".price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("#cover")[:src]
    
    elsif store == "Barnes and Noble"
      name = doc.at_css("h1").text.strip
      price = doc.at_css(".price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_xpath("//meta[@property='og:image']/@content").value
    
    elsif store == "Steam"
      name = doc.at_css(".apphub_AppName").text.strip
      price = doc.at_css(".game_purchase_price").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css(".game_header_image")[:src]
    
    elsif store == "Sur La Table"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    
    elsif store == "Lulu Lemon"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    
    elsif store == "Lucy"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    
    elsif store == "H and M"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    
    elsif store == "Anthropologie"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    
    elsif store == "Ikea"
      name = doc.at_css("").text.strip
      price = doc.at_css("").text[/\d+(\.\d{1,2})?/]
      image = doc.at_css("")[:src]
    # Catch all for other stores that are not hard-coded
    else
      meta_name = check_meta_name(doc)
      meta_image = check_meta_image(doc)
      
      if meta_image
        image = meta_image
      else
        image_divs = [".product-images img", "#product-images img", ".main-images img", "#main-images img", ".main_image img", "#main_image img", ".main-image img", "#main-image img", ".mainImage img", "#mainImage img", ".product_image img", ".product-image img", "#product-image img", "#product_image img", ".productImage img", "#mainImage img", ".image img", "#image img", ".main_image", "#main_image", ".main-image", "#main-image", "#product-image", "#product_image", ".mainImage", "#mainImage", ".product_image", "#product_image", ".productImage", "#mainImage", ".image", "#image", "#hero", "#heroImage", "#primary-image", ".primary-image", "#mainImg", "#featuredImg", "#productMainImage", "#productMainImage img", "img.hero" ]
        images = []

        image_divs.each do |img|
          if doc.at_css(img)
            img_source = doc.at_css(img)[:src]
            images << img_source
          end
        end

        # setting image  
        if images.empty? || images == [""]
          images = doc.css('img').select{|img| img[:width].to_i > 100}
          images = images.map{ |img| img[:src] }
          image = images.first
          if image.nil?
            image = nil
          end
        else
          image = images.first
          if image == "" || image == "/"
            image = nil
          end
        end
      end
      # searching for random images
      

      # searching for the price
      price = nil
      price_divs = [".price", "#price", ".productPrice", "#productPrice", ".product_price", "#product_price", ".price_container", "#price_container", "#priceContainer", ".priceContainer", ".price-amount", ".offerPrice", "#price-container", ".price-container", "#priceText"]
      price_divs.each do |price|
        price = doc.at_css(price).text unless doc.at_css(price).nil?
      end

      # setting the price
      if price.nil?
        els = doc.search "[text()*='$']"
        el = els.first
        if el
          price_container = el.parent
          price = price_container.text.strip[/\d+(\.\d{1,2})?/]
        else
          price = "unknown"
        end
      else
        price = price.strip[/\d+(\.\d{1,2})?/]
      end

      # searching for the product name
      if meta_name
        name = meta_name
      else
        name = doc.at_css("title")

        # setting the name
        if name.nil?
          name = "unknown"
        else
          name = doc.at_css("title").text.strip
          if name.include? '|'
            name = doc.at_css("title").text[/\A(.*?)\|/]
          elsif name.include? '-'
            name = doc.at_css("title").text[/\A(.*?)-/]
          else
            name = doc.at_css("title").text
          end
        end
      end
    end
    return name, price, url, store, image
    
  end
  
  def check_meta_image(doc)
    if doc.at_xpath("//meta[@property='og:image']/@content")
      image = doc.at_xpath("//meta[@property='og:image']/@content").value
      return image
    else
      return false
    end
  end
  
  def check_meta_name(doc)
    if doc.at_xpath("//meta[@property='og:title']/@content")
      name = doc.at_xpath("//meta[@property='og:title']/@content").value
      return name
    else
      return false
    end
  end
  
  def parse_url(url)
    host = URI.parse(url).host.downcase
    if host == "www.amazon.com" || host == "amazon.com"
      return "Amazon"
    elsif host == "www.walmart.com" || host == "walmart.com"
      return "Walmart"
    elsif host == "www.bestbuy.com" || host == "bestbuy.com"
      return "Bestbuy"
    elsif host == "www.apple.com" || host == "apple.com" || host == "store.apple.com"
      return "Apple"
    elsif host == "www.sears.com" || host == "sears.com"
      return "Sears"
    elsif host == "www.nordstrom.com" || host == "nordstrom.com" || host == "shop.nordstrom.com"
      return "Nordstrom"
    elsif host == "www1.macys.com" || host == "wwww.macys.com" || host == "macys.com"
      return "Macys"
    elsif host == "www.etsy.com"
      return "Etsy"
    elsif host == "www.rei.com"
      return "REI"
    elsif host == "Gap"
      return "www.gap.com"
    elsif host == "www.jcrew.com"
      return "J. Crew"
    elsif host == "bananarepublic.gap.com"
      return "Banana Republic"
    elsif host == "www.bedbathandbeyond.com"
      return "Bed Bath and Beyond"
    elsif host == "www.everlane.com"
      return "Everlane"
    elsif host == "www.warbyparker.com"
      return "Warby Parker"
    elsif host == "www.target.com"
      return "Target"
    elsif host == "www.williams-sonoma.com"
      return "Williams and Sonoma"
    elsif host == "www.uncrate.com"
      return "Uncrate"
    elsif host == "www.kickstarter.com"
      return "Kickstarter"
    elsif host == "www.newegg.com"
      return "Newegg"
    elsif host == "www.pier1.com"
      return "Pier 1"
    elsif host == "www.potterybarn.com"
      return "Pottery Barn"
    elsif host == "www.crateandbarrel.com"
      return "Crate & Barrel"
    elsif host == "www.kmart.com"
      return "kmart"
    elsif host == "www.jcpenney.com"
      return "jcp"
    elsif host == "www.worldmarket.com"
      return "World Market"
    elsif host == "www.sierratradingpost.com"
      return "Sierra Trading Post"
    elsif host == "www.eddiebauer.com"
      return "Eddie Bauer"
    elsif host == "www.llbean.com"
      return "L.L. Bean"
    elsif host == "www.costco.com"
      return "Costco"
    elsif host == "www.powells.com"
      return "Powell's"
    elsif host == "www.barnesandnoble.com"
      return "Barnes and Noble"
    elsif host == "store.steampowered.com"
      return "Steam"
    else
      host = host.to_s.gsub("www.", "")
      host = host.to_s.gsub(".com", "")
      host = host.to_s.capitalize
      return host
    end
  end
  
  def claimed_by_user
    unless self.claimed_by.nil?
      user = self.claimed_by
      user = User.find(user)
      return user
    end
  end
  
  def check_info
    if name.blank?
      self.delete
    end
  end
end
