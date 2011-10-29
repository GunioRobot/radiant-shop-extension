class ShopExtension < Radiant::Extension
  version YAML::load_file(File.join(File.dirname(__FILE__), 'VERSION'))
  description "Radiant Shop provides"
  url "http://github.com/dirkkelly/radiant-shop-extension"

  extension_config do |config|
    config.gem 'activemerchant',              :lib => 'active_merchant'
    config.gem 'fastercsv',                   :lib => 'fastercsv'
    config.gem 'radiant-settings-extension',  :lib => false
    config.gem 'radiant-users-extension'
    config.gem 'radiant-images-extension'
    config.gem 'radiant-forms-extension'
    config.gem 'radiant-drag_order-extension'
  end

  UserActionObserver.instance.send :add_observer!, ShopCategory
  UserActionObserver.instance.send :add_observer!, ShopOrder
  UserActionObserver.instance.send :add_observer!, ShopProduct

  def activate
    tab "Shop" do
      add_item "Products",  "/admin/shop"
      add_item "Orders",    "/admin/shop/orders"
      add_item "Customers", "/admin/shop/customers"
    end

    unless defined? admin.products
      Radiant::AdminUI.send :include, Shop::Interface::Categories, Shop::Interface::Customers
      Radiant::AdminUI.send :include, Shop::Interface::Discounts,  Shop::Interface::Orders,    Shop::Interface::Products

      admin.categories = Radiant::AdminUI.load_default_shop_categories_regions
      admin.customers  = Radiant::AdminUI.load_default_shop_customers_regions
      admin.discounts  = Radiant::AdminUI.load_default_shop_discounts_regions
      admin.orders     = Radiant::AdminUI.load_default_shop_orders_regions
      admin.products   = Radiant::AdminUI.load_default_shop_products_regions
    end

    Page.send :include,  Shop::Models::Page
    User.send :include,  Shop::Models::User

    ApplicationController.send :include, Shop::Controllers::ApplicationController
    SiteController.send :include, Shop::Controllers::SiteController

    Page.send :include, Shop::Tags::Core,     Shop::Tags::Address, Shop::Tags::Card,    Shop::Tags::Cart
    Page.send :include, Shop::Tags::Category, Shop::Tags::Item,    Shop::Tags::Product
    Page.send :include, Shop::Tags::Tax

    Radiant::Config['shop.layout_product']  ||= 'Product'
    Radiant::Config['shop.layout_category'] ||= 'Products'

    Radiant::Config['shop.price_unit']      ||= '$'
    Radiant::Config['shop.price_precision'] ||= 2
    Radiant::Config['shop.price_separator'] ||= '.'
    Radiant::Config['shop.price_delimiter'] ||= ','

    Radiant::Config['shop.tax_strategy']    ||= 'inclusive'
    Radiant::Config['shop.tax_percentage']  ||= '10'
    Radiant::Config['shop.tax_name']        ||= 'gst'

    Radiant::Config['shop.date_format']     ||= '%d/%m/%Y'

    Radiant::Config['users.customer.redirect'] = '/cart'

  end

end
