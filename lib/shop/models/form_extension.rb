module Shop
  module Models
    module FormExtension

      def self.included(base)
        base.class_eval do
          # Uses the page session data to find the current order
          def find_current_order
            @order = ShopOrder.find_by_session(@page.request.session[:shop_order])
          end

          # Uses the page session data to find or create the current order
          def find_or_create_current_order
            begin
              @order = find_current_order
            rescue
              @order = ShopOrder.create
              @result[:session] = { :shop_order => @order.id }
            end

            if current_user
              @order.update_attribute(:customer_id, (current_user.id))
            end

            @order
          end
        end
      end
    end
  end
end