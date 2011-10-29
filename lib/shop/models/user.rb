module Shop
  module Models
    module User

      def self.included(base)
        base.class_eval do
          has_one    :billing,  :class_name => 'ShopBilling',   :as => :addressable
          has_one    :shipping, :class_name => 'ShopShipping',  :as => :addressable
          has_many   :orders,   :class_name => 'ShopOrder',     :foreign_key => :customer_id

          accepts_nested_attributes_for :orders, :shipping, :billing
        end
      end

    end
  end
end