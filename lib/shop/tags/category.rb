module Shop
  module Tags
    module Category
      include Radiant::Taggable

      tag 'shop:categories' do |tag|
        tag.locals.shop_categories = Helpers.current_categories(tag)
        tag.expand
      end

      desc %{ expands if there are shop categories within the context }
      tag 'shop:categories:if_categories' do |tag|
        tag.expand if tag.locals.shop_categories.present?
      end

      desc %{ expands if there are not shop categories within the context }
      tag 'shop:categories:unless_categories' do |tag|
        tag.expand if tag.locals.shop_categories.empty?
      end

      desc %{ iterates through each product category }
      tag 'shop:categories:each' do |tag|
        content = ''
        categories = tag.locals.shop_categories

        categories.each do |category|
          tag.locals.shop_category = category
          content << tag.expand
        end

        content
      end

      tag 'shop:category' do |tag|
        tag.locals.shop_category = Helpers.current_category(tag)
        if tag.locals.shop_category.present?
          tag.locals.shop_categories = tag.locals.shop_category.categories
        end

        tag.expand unless tag.locals.shop_category.nil?
      end

      tag 'shop:category:if_current' do |tag|

        if tag.globals.page.shop_category == tag.locals.shop_category
          # Looking at the shop_category generated page
          tag.expand

        elsif tag.globals.page.shop_product.present?
          # A product page
          if tag.globals.page.shop_product.category == tag.locals.shop_category
            # Where the products category is this category
            tag.expand
          end
        end

      end

      tag 'shop:category:unless_current' do |tag|

        if tag.globals.page.shop_product.present?
          # A product page
          if tag.globals.page.shop_product.category != tag.locals.shop_category
            # Where the products category is this category
            tag.expand
          end

        elsif tag.globals.page.shop_category != tag.locals.shop_category
          # Looking at the shop_category generated page
          tag.expand

        end

      end

      [:id, :name, :handle, :slug, :url].each do |symbol|
        desc %{ outputs the #{symbol} of the current shop category }
        tag "shop:category:#{symbol}" do |tag|
          tag.locals.shop_category.send(symbol)
        end
      end

      desc %{ outputs the description of the current shop category }
      tag "shop:category:description" do |tag|
        tag.locals.shop_category.description
      end

      desc %{ returns a link to the current category }
      tag 'shop:category:link' do |tag|
        category = tag.locals.shop_category
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?

        text = tag.double? ? tag.expand : category.name

        %{<a href="#{category.url}"#{attributes}>#{text}</a>}
      end

      tag 'shop:category:images' do |tag|
        tag.locals.images = tag.locals.shop_category.attachments

        tag.expand
      end

    end
  end
end