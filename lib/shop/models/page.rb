module Shop
  module Models
    module Page

      def self.included(base)
        base.class_eval do
          has_one :shop_category, :dependent => :delete
          has_one :shop_product,  :dependent => :delete
        end
      end

    end
  end
end