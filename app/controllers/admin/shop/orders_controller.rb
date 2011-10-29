require 'fastercsv'

class Admin::Shop::OrdersController < Admin::ResourceController
  model_class ShopOrder
  paginate_models :per_page => 15

  before_filter :config_global
  before_filter :config_index,  :only => [ :index ]
  before_filter :config_new,    :only => [ :new, :create ]
  before_filter :config_edit,   :only => [ :edit, :update ]
  before_filter :assets_global
  before_filter :assets_index,  :only => [ :index ]
  before_filter :assets_edit,   :only => [ :edit, :update ]

  alias_method :resource_controller_loads_models, :load_models
  # Applies a scope to the orders result based on the params status
  def load_models
    model_class.scope_by_status(params[:status]) do
      resource_controller_loads_models
    end
  end

  # You can overide this to export what you desire
  def export

  end


  protected

    def config_global
      @inputs   ||= []
      @meta     ||= []
      @buttons  ||= []
      @parts    ||= []
      @popups   ||= []
    end

    def config_index
      @buttons  << 'all'
      @buttons  << 'new'
      #@buttons  << 'shipped'
      @buttons  << 'paid'
    end

    def config_new
    end

    def config_edit
      @parts    << 'items'
      @parts    << 'addresses' if @shop_order.billing.present?
      @parts    << 'customer'  if @shop_order.customer.present?
    end

    def assets_global
      include_stylesheet 'admin/extensions/shop/edit'
      include_stylesheet 'admin/extensions/shop/index'
    end

    def assets_index
    end

    def assets_edit
    end

end
