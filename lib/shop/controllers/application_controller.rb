module Shop
  module Controllers
    module ApplicationController

      def self.included(base)
        base.class_eval do
          filter_parameter_logging :password, :password_confirmation, :credit

          def current_shop_order
            find_or_create_shop_order
          end

          def find_shop_order
            ShopOrder.find_by_session(request.session[:shop_order])
          end

          def find_or_create_shop_order
            begin
              @order = find_shop_order
            rescue
              @order = ShopOrder.create
              request.session[:shop_order] = @order.id
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