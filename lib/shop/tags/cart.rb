module Shop
  module Tags
    module Cart
      include Radiant::Taggable
      include ActionView::Helpers::NumberHelper

      # Expand the shopping cart instance
      # @param [Integer] id Id of the shopping cart (ShopOrder)
      tag 'shop:cart' do |tag|
        tag.locals.shop_order = Helpers.current_order(tag)
        tag.expand
      end

      desc %{ Clears the cart from the memory of the application}
      tag 'shop:cart:forget' do |tag|
        tag.locals.page.request.session[:shop_order] = nil
      end

      # Expand if a user has started a cart
      desc %{ Expand if a user has started a cart }
      tag 'shop:cart:if_cart' do |tag|
        tag.expand if tag.locals.shop_order.present?
      end

      # Expand unless a user has started a cart
      desc %{ Expand unless a user has started a cart }
      tag 'shop:cart:unless_cart' do |tag|
        tag.expand unless tag.locals.shop_order.present?
      end

      # Expand the payment context for the cart
      desc %{ Expand the payment context for the cart }
      tag 'shop:cart:payment' do |tag|
        tag.expand
      end

      # Expand if the user has paid for their cart
      desc %{ Expand if the user has paid for their cart }
      tag 'shop:cart:payment:if_paid' do |tag|
        tag.expand if tag.locals.shop_order.payment.present? and tag.locals.shop_order.paid?
      end

      # Expand unless the user has paid for their cart
      desc %{ Expand unless the user has paid for their cart }
      tag 'shop:cart:payment:unless_paid' do |tag|
        tag.expand unless tag.locals.shop_order.payment.present? and tag.locals.shop_order.paid?
      end

      # Returns the date of the payment
      desc %{ Returns the date of the payment }
      tag 'shop:cart:payment:date' do |tag|
        tag.locals.shop_order.payment.created_at.strftime(Radiant::Config['shop.date_format'])
      end

      # Display the cart id / status
      [:id, :status, :quantity, :weight, :notes].each do |symbol|
        desc %{ outputs the #{symbol} to the cart }
        tag "shop:cart:#{symbol}" do |tag|
          tag.locals.shop_order.send(symbol)
        end
      end

      # Display the total price of the items in the shopping basket.
      desc %{ Output the total price of the items in the shopping basket. }
      tag 'shop:cart:price' do |tag|
        attr = tag.attr.symbolize_keys
        order = tag.locals.shop_order

        Helpers.currency(order.price,attr)
      end

    end
  end
end