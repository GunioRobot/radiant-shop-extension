module Shop
  module Tags
    module Product
      include Radiant::Taggable

      tag 'shop:products' do |tag|
        tag.locals.shop_products = Helpers.current_products(tag)

        tag.expand
      end

      desc %{ expands if there are products within the context }
      tag 'shop:products:if_products' do |tag|
        tag.expand unless tag.locals.shop_products.empty?
      end

      desc %{ expands if there are no products within the context }
      tag 'shop:products:unless_products' do |tag|
        tag.expand if tag.locals.shop_products.empty?
      end

      desc %{ iterates through each product within the scope }
      tag 'shop:products:each' do |tag|
        content = ''

        tag.locals.shop_products.each do |product|
          tag.locals.shop_product = product
          content << tag.expand
        end

        content
      end

      tag 'shop:product' do |tag|
        tag.locals.shop_product = Helpers.current_product(tag)

        tag.expand if tag.locals.shop_product.present?
      end

      tag 'shop:product:page' do |tag|
        tag.locals.page = tag.locals.shop_product.page

        tag.expand
      end

      tag 'shop:product:if_current' do |tag|
        if tag.globals.page.shop_product == tag.locals.shop_product
          tag.expand
        end
      end

      tag 'shop:product:unless_current' do |tag|
        if tag.globals.page.shop_product != tag.locals.shop_product
          tag.expand
        end
      end

      [:id, :name, :sku, :slug].each do |symbol|
        desc %{ outputs the #{symbol} of the current shop product }
        tag "shop:product:#{symbol}" do |tag|
          tag.locals.shop_product.send(symbol)
        end
      end

      desc %{ outputs the description of the current shop product}
      tag "shop:product:description" do |tag|
        tag.locals.shop_product.description
      end

      desc %{ generates a link to the products generated page }
      tag 'shop:product:link' do |tag|
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" if attributes.present?

        text = tag.double? ? tag.expand : tag.locals.shop_product.name

        %{<a href="#{tag.locals.shop_product.url}"#{attributes}>#{text}</a>}
      end

      desc %{ outputs the slug to the products generated page }
      tag 'shop:product:slug' do |tag|
        tag.locals.shop_product.slug
      end

      desc %{ output price of product }
      tag 'shop:product:price' do |tag|
        attr = tag.attr.symbolize_keys

        Helpers.currency(tag.locals.shop_product.price,attr)
      end

      tag 'shop:product:images' do |tag|
        tag.locals.images = tag.locals.shop_product.attachments

        tag.locals.images = Images::Tags::Helpers.current_images(tag)

        tag.expand
      end

    end
  end
end