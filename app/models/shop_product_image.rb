class ShopProductImage < ActiveRecord::Base
  
  belongs_to :product, :class_name => 'ShopProduct'
  belongs_to :asset, :class_name => 'Asset', :foreign_key => 'asset_id'

  acts_as_list :scope => :product_id
  
end