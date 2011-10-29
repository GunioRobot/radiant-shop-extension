module Shop
  module Tags
    class Helpers
      class << self
        include ActionView::Helpers::NumberHelper

        def current_categories(tag)
          result = []

          # Returns categories based on the slug of their categories parent page
          if tag.attr['parent']
            result = ShopCategory.all(
                       :joins      => 'JOIN pages AS page ON page.id = shop_categories.page_id JOIN pages AS parent ON page.parent_id = parent.id',
                       :conditions => [ 'parent.slug = ?', tag.attr['parent'] ]
                     )

          # Returns the current categories if they exist
          elsif tag.locals.shop_categories.present?
            result = tag.locals.shop_categories

          # Page params are protected, send is used to overcome this
          # elsif tag.locals.page.send(:params).has_key? 'query'
          #   result = ShopCategory.search(tag.locals.page.send(:params)['query'])

          # Returns all Categories
          else
            result = ShopCategory.all

          end

          result
        end

        def current_category(tag)
          result = nil

          # Returns a category based on its name (page title)
          if tag.attr['name']
            result = ShopCategory.first(
                       :joins      => :page,
                       :conditions => [ "pages.title = ?", tag.attr['name'] ]
                     )

          # Returns a category based on its handle (page slug)
          elsif tag.attr['handle']
            result = ShopCategory.first(
                       :joins      => :page,
                       :conditions => [ "pages.slug = ?", tag.attr['handle'] ]
                     )

          # Returns the current shop_category
          elsif tag.locals.shop_category.present?
            result = tag.locals.shop_category

          # Returns the category of the current shop_product
          elsif tag.locals.shop_product.present?
             result = tag.locals.shop_product.category

          elsif tag.locals.page.shop_category.present?
            result = tag.locals.page.shop_category

          elsif tag.locals.page.shop_product.present?
            result = tag.locals.page.shop_product.category

          end

          result
        end

        def current_products(tag)
          result = nil

          if tag.attr['category']
            result = ShopCategory.first(
                       :joins      => :page,
                       :conditions => [ 'pages.slug = ?', tag.attr['category'] ]
                     ).products

          elsif tag.locals.shop_products.present?
            result = tag.locals.shop_products

          elsif tag.locals.shop_category.present?
            result = tag.locals.shop_category.products

          elsif tag.locals.page.shop_category.present?
            result = tag.locals.page.shop_category.products

          else
            result = ShopProduct.all

          end

          result
        end

        def current_product(tag)
          result = nil

          # Returns a product based on its name (page title)
          if tag.attr['name']
            result = ShopProduct.first(
                       :joins      => :page,
                       :conditions => [ "pages.title = ?", tag.attr['name'] ]
                     )

          # Returns a product based on its sku (page slug)
          elsif tag.attr['sku']
            result = ShopProduct.first(
                       :joins      => :page,
                       :conditions => [ "pages.slug = ?", tag.attr['sku'] ]
                     )

          elsif tag.locals.shop_product.present?
            result = tag.locals.shop_product

          elsif tag.attr['position']
            children = tag.locals.shop_category.page.children
            result = children.first(:conditions => { :class_name => 'ShopProductPage', :position => tag.attr['position'].to_i }) || children.first(:conditions => {:class_name => 'ShopProductPage'})
            result = result.shop_product

          elsif tag.locals.shop_line_item.present? and tag.locals.shop_line_item.item_type === 'ShopProduct'
            result = tag.locals.shop_line_item.item

          elsif tag.locals.page.shop_product.present?
            result = tag.locals.page.shop_product

          end

          result
        end

        def current_image(tag)
          result = nil

          if tag.attr['position']
            result = tag.locals.images.find_by_position(tag.attr['position'].to_i)

          elsif tag.locals.image.present?
            result = tag.locals.image.image rescue tag.locals.image

          end

          result
        end

        def current_order(tag)
          result = nil
          begin
            if tag.attr['key'] and tag.attr['value']
              result  = ShopOrder.first(:conditions => { tag.attr['key'].downcase.to_sym => tag.attr['value'] })

            elsif tag.locals.shop_order.present?
              result  = tag.locals.shop_order

            elsif tag.locals.page.request.session[:shop_order].present?
              session = tag.locals.page.request.session[:shop_order]
              result  = ShopOrder.find(session)

            elsif tag.locals.response.present? and tag.locals.response.result[:checkout].present?
              result  = ShopOrder.find(tag.locals.response.result[:checkout][:order])

            end
          rescue
            result = nil
          end

          result
        end

        def current_line_items(tag)
          result = nil

          if tag.locals.shop_line_items.present?
            result = tag.locals.shop_line_items
          else
            result = tag.locals.shop_order.line_items
          end

          result
        end

        def current_line_item(tag)
          result = nil

          if tag.locals.shop_line_item.present?
            result  = tag.locals.shop_line_item

          elsif tag.locals.shop_order.present? and tag.locals.shop_product.present?
            result  = tag.locals.shop_order.line_items.find_by_item_id(tag.locals.shop_product.id)

          end

          result
        end

        # Return the current address for the current order
        # of_type = the address type (billing|shipping)
        def current_address(tag,of_type = 'billing')
          if tag.locals.send(of_type).present?
            return tag.locals.send(of_type)
          end

          if tag.locals.shop_order.present?
            begin
              # Get the address type (order.billing)
              address = tag.locals.shop_order.send(of_type)
              return address unless address.nil?
            rescue
              nil
            end
          end

          if user = Users::Tags::Helpers.current_user(tag)
            begin
              address = user.send(of_type)
              return address unless address.nil?
            rescue
              nil
            end
          end

          nil
        end

        def currency(number,attr = {})
          precision = attr[:precision].present? ? attr[:precision] : Radiant::Config['shop.price_precision']
          unit      = attr[:unit].present?      ? attr[:unit]      : Radiant::Config['shop.price_unit']
          separator = attr[:separator].present? ? attr[:separator] : Radiant::Config['shop.price_separator']
          delimiter = attr[:delimiter].present? ? attr[:delimiter] : Radiant::Config['shop.price_delimiter']

          number_to_currency(number.to_f, {
            :precision  => precision.to_i,
            :unit       => unit,
            :separator  => separator,
            :delimiter  => delimiter
          })
        end

      end
    end
  end
end