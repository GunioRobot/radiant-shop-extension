class ShopConfigDataset < Dataset::Base

  def load
    Radiant::Config['shop.root_page_id']        = pages(:home).id

    Radiant::Config['shop.layout_product']      = 'Product'
    Radiant::Config['shop.layout_category']     = 'Products'

    Radiant::Config['shop.price_unit']          = '$'
    Radiant::Config['shop.price_precision']     = 2
    Radiant::Config['shop.price_separator']     = '.'
    Radiant::Config['shop.price_delimiter']     = ','

    Radiant::Config['shop.tax_strategy']        = 'inclusive'
    Radiant::Config['shop.tax_percentage']      = '10'
    Radiant::Config['shop.tax_name']            = 'gst'

    Radiant::Config['shop.date_format']         = '%d/%m/%Y'

    # Scoped Customer Welcome Page
    Radiant::Config['scoped.customer.redirect'] = '/cart'
  end

end