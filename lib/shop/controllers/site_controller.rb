module Shop
  module Controllers
    module SiteController

      def self.included(base)
        base.class_eval do
          #before_filter :current_shop_order
        end
      end
    end
  end
end