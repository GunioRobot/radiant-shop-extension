module ShopProducts
  module ProductExtensions
    def self.included(base)
      base.class_eval do
        def slug
          self.slug_prefix + '/' + self.category.handle + '/' + self.handle
        end
      
        def layout
          self.category.product_layout
        end
      
        def assets_available
          Asset.search('', {:image => 1}) - self.assets
        end
        
        def slug_prefix
          Radiant::Config['shop.url_prefix']
        end
      end
    end
  end
end