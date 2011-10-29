module Shop
  module Tags
    module Tax
      include Radiant::Taggable

      # Expand regardless of tax conditions
      tag 'shop:cart:tax' do |tag|
        tag.locals.shop_tax = {
          :strategy   => Radiant::Config['shop.tax_strategy'],
          :name       => Radiant::Config['shop.tax_name'],
          :percentage => Radiant::Config['shop.tax_percentage'],
        }
        tag.expand
      end

      # Expand if tax is configured
      desc %{ Expand if tax is configured }
      tag 'shop:cart:tax:if_tax' do |tag|
         tag.expand if ['inclusive','exclusive'].include?(tag.locals.shop_tax[:strategy])
      end

      # Expand unless tax is configured
      desc %{ Expand unless tax is configured }
      tag 'shop:cart:tax:unless_tax' do |tag|
         tag.expand unless ['inclusive','exclusive'].include?(tag.locals.shop_tax[:strategy])
      end

      # Return the strategy of the tax
      desc %{ Return the name of the tax }
      tag 'shop:cart:tax:strategy' do |tag|
         tag.locals.shop_tax[:strategy]
      end

      # Return the strategy of the tax
      desc %{ Return the name of the tax }
      tag 'shop:cart:tax:strategy' do |tag|
         tag.locals.shop_tax[:strategy]
      end

      # Return the name of the tax
      desc %{ Return the name of the tax }
      tag 'shop:cart:tax:name' do |tag|
        tag.locals.shop_tax[:name]
      end

      # Return the percentage of the tax
      desc %{ Return the name of the tax }
      tag 'shop:cart:tax:percentage' do |tag|
         tag.locals.shop_tax[:percentage]
      end

      # Return the cost of tax on the cart
      desc %{ Return the cost of tax on the cart }
      tag 'shop:cart:tax:cost' do |tag|
        attr = tag.attr.symbolize_keys
        Helpers.currency(tag.locals.shop_order.tax,attr)
      end

      # Expand if tax is inclusive
      desc %{ Expand if tax is inclusive }
      tag 'shop:cart:tax:if_inclusive' do |tag|
         tag.expand if tag.locals.shop_tax[:strategy] === 'inclusive'
      end

      # Expand if tax is exclusive
      desc %{ Expand if tax is exclusive }
      tag 'shop:cart:tax:if_exclusive' do |tag|
         tag.expand if tag.locals.shop_tax[:strategy] === 'exclusive'
      end

    end
  end
end
