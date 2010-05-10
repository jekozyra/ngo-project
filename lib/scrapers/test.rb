#!/usr/bin/env ruby

require '../../config/environment' #only if you are using this within a rails app
require 'rubygems'
require 'scrubyt'
Scrubyt.logger = Scrubyt::Logger.new
product_data = Scrubyt:: Extractor.define do

  fetch 'http://www.homedepot.com/webapp/wcs/stores/servlet/HomePageView?storeId=10051&catalogId=10053&langId=-1'
  fill_textfield 'keyword', 'hoover vacuums'
  submit

  #identify the products in the search results and creating a pattern
  product_row "//div[@class='product']" do
    #finding the link to the product details page
    product_link "/form/div[1]/p[1]/a", :generalize => false do
      #following the link        
      product_details do
        #grabbing the data
        product_record "//p[@class='product-name']" do
           title "Homelite 20 In. Homelite Corded Electric Mower"
        end
        parent "//div[@id='tab-features']" do
          description "/p[1]"
        end
      end
    end
  end
end
#saving the data to mysql, requires the environment line above
product_data_hash = product_data.to_hash
product_data_hash.each do |item|
  @product = Product.create(item)
  @product.save
end