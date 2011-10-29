module Shop
  module Tags
    module Item
      include Radiant::Taggable
      include ActionView::Helpers::NumberHelper

      # Expand to line items
      tag 'shop:cart:items' do |tag|
        if tag.locals.shop_order.present?
          tag.locals.shop_line_items = Helpers.current_line_items(tag)
          tag.expand
        end
      end

      # Expand if items are in cart
      desc %{ Expand if the user has added items to their cart }
      tag 'shop:cart:items:if_items' do |tag|
        tag.expand unless tag.locals.shop_line_items.empty?
      end

      # Expand in no items are in cart
      desc %{ Expand unless a user has added items to their cart }
      tag 'shop:cart:items:unless_items' do |tag|
        tag.expand if tag.locals.shop_line_items.empty?
      end

      # Iterate through each item in the cart
      desc %{ Iterate through each item in the cart }
      tag 'shop:cart:items:each' do |tag|
        content = ''
        items = tag.locals.shop_line_items

        items.each do |line_item|
          tag.locals.shop_line_item = line_item
          content << tag.expand
        end

        content
      end

      # Assigns the line item and expands the context
      desc %{ Expand the current line item }
      tag 'shop:cart:item' do |tag|
        tag.locals.shop_line_item = Helpers.current_line_item(tag)

        if tag.locals.shop_line_item.present?
          tag.locals.shop_product = tag.locals.shop_line_item.item

          tag.expand
        end
      end

      # Output the line item id/quantity/weight
      [:id, :quantity].each do |symbol|
        desc %{ outputs the #{symbol} of the current cart item }
        tag "shop:cart:item:#{symbol}" do |tag|
          tag.locals.shop_line_item.send(symbol)
        end
      end

      # Output the related elements attributes
      [:name, :sku].each do |symbol|
        desc %{ outputs the #{symbol} of the current cart item }
        tag "shop:cart:item:#{symbol}" do |tag|
          tag.locals.shop_line_item.item.send(symbol)
        end
      end

      [:price].each do |symbol|
        desc %{ outputs the #{symbol} of the current cart item }
        tag "shop:cart:item:#{symbol}" do |tag|
          attr = tag.attr.symbolize_keys
          item = tag.locals.shop_line_item

          Helpers.currency(item.send(symbol),attr)
        end
      end

      desc %{ generates a link to the items generated page }
      tag 'shop:cart:item:link' do |tag|
        item = tag.locals.shop_line_item.item
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?

        text = tag.double? ? tag.expand : item.name

        %{<a href="#{item.url}"#{attributes}>#{text}</a>}
      end

    end
  end
end