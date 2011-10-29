class Admin::Shop::ProductsController < Admin::ResourceController

  model_class ShopProduct

  helper :shop

  before_filter :config_global
  before_filter :config_index,  :only => [ :index ]
  before_filter :config_new,    :only => [ :new, :create ]
  before_filter :config_edit,   :only => [ :edit, :update ]
  before_filter :assets_global
  before_filter :assets_index,  :only => [ :index ]
  before_filter :assets_edit,   :only => [ :edit, :update ]

  before_filter :set_layout_and_page,  :only => [ :new ]

  # GET /admin/shop/products
  # GET /admin/shop/products.js
  # GET /admin/shop/products.json                                 AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @shop_categories = ShopCategory.all

    respond_to do |format|
      format.html { render :index }
      format.js   { render :partial => '/admin/shop/products/index/product', :collection => @shop_products }
      format.json { render :json    => @shop_products.to_json }
    end
  end

  # PUT /admin/shop/products/sort
  # PUT /admin/shop/products/sort.js
  # PUT /admin/shop/products/sort.json                            AJAX and HTML
  #----------------------------------------------------------------------------
  def sort
    notice = 'Products successfully sorted.'
    error  = 'Could not sort Products.'

    begin
      ShopProduct.sort(params[:category_id], CGI::parse(params[:products])["category_#{params[:category_id]}_products[]"])

      respond_to do |format|
        format.html {
          redirect_to admin_shop_products_path
        }
        format.js   { render  :text => notice, :status => :ok }
        format.json { render  :json => { :notice => notice }, :status => :ok }
      end
    rescue
      respond_to do |format|
        format.html {
          flash[:error] = error
          redirect_to admin_shop_products_path
        }
        format.js   { render  :text => error, :status => :unprocessable_entity }
        format.json { render  :json => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # POST /admin/shop/products
  # POST /admin/shop/products.js
  # POST /admin/shop/products.json                                AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    notice = 'Product created successfully.'
    error = 'Could not create Product.'

    @shop_product.attributes = params[:shop_product]

    begin
      @shop_product.save!

      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_product_path(@shop_product) if params[:continue]
          redirect_to admin_shop_products_path unless params[:continue]
        }
        format.js   { render :partial => '/admin/shop/products/index/product', :locals => { :excerpt => @shop_product } }
        format.json { render :json    => @shop_product.to_json }
      end
    rescue Exception => error
      respond_to do |format|
        format.html {
          flash[:error] = error
          render :new
        }
        format.js   { render :text => error, :status => :unprocessable_entity }
        format.json { render :json => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/shop/products/1
  # PUT /admin/shop/products/1.js
  # PUT /admin/shop/products/1.xml
  # PUT /admin/shop/products/1.json                               AJAX and HTML
  #----------------------------------------------------------------------------
  def update
    notice = 'Product updated successfully.'
    error = 'Could not update Product.'

    begin
      @shop_product.update_attributes!(params[:shop_product])

      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_product_path(@shop_product) if params[:continue]
          redirect_to admin_shop_products_path unless params[:continue]
        }
        format.js   { render  :partial  => '/admin/shop/products/index/product', :locals => { :product => @shop_product } }
        format.json { render  :json     => @shop_product.to_json }
      end
    rescue Exception => error
      respond_to do |format|
        format.html {
          flash[:error] = error
          render :edit
        }
        format.js   { render  :text => error, :status => :unprocessable_entity }
        format.json { render  :json => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/shop/products/1
  # DELETE /admin/shop/products/1.js
  # DELETE /admin/shop/products/1.xml
  # DELETE /admin/shop/products/1.json                            AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    notice = 'Product deleted successfully.'

    @shop_product.destroy

    respond_to do |format|
      format.html {
        redirect_to admin_shop_products_path
      }
      format.js   { render  :text => notice, :status => :ok }
      format.json { render  :json => { :notice => notice }, :status => :ok }
    end
  end

private

  def config_global
    @inputs   ||= []
    @meta     ||= []
    @buttons  ||= []
    @parts    ||= []
    @popups   ||= []

    @inputs   << 'name'
    @inputs   << 'price'

    @meta     << 'sku'
    @meta     << 'page'
    @meta     << 'category'
    @meta     << 'layout'
    @meta     << 'status'

    @parts    << 'description'
  end

  def config_index
    @buttons  << 'add_category'
  end

  def config_new
  end

  def config_edit
    @parts    << 'images'
    @parts    << 'customers'

    @buttons  << 'browse_images'
    @buttons  << 'new_image'

    @popups   << 'browse_images'
    @popups   << 'new_image'
  end

  def assets_global
  end

  def assets_index
    include_stylesheet 'admin/extensions/shop/index'
    include_stylesheet 'admin/extensions/shop/products/index'

    include_javascript 'admin/dragdrop'
    include_javascript 'admin/extensions/shop/edit'
    include_javascript 'admin/extensions/shop/products/index'
  end

  def assets_edit
    include_stylesheet 'admin/extensions/shop/edit'
    include_stylesheet 'admin/extensions/shop/products/edit'

    include_javascript 'admin/dragdrop'
    include_javascript 'admin/extensions/shop/edit'
    include_javascript 'admin/extensions/shop/products/edit'


    @routes = [
      {
        :name => 'admin_shop_product_images_path',
        :path => admin_shop_product_images_path(@shop_product)
      },
      {
        :name => 'sort_admin_shop_product_images_path',
        :path => sort_admin_shop_product_images_path(@shop_product)
      },
      {
        :name => 'admin_shop_product_image_path',
        :path => admin_shop_product_image_path(@shop_product, ':id')
      }
    ]
  end

  def set_layout_and_page
    @shop_category = ShopCategory.find(params[:category_id])
    @shop_product.page = Page.new(
      :parent_id  => @shop_category.page_id,
      :layout_id  => @shop_category.product_layout_id,
      :parts      => [PagePart.new(:name => 'description', :filter_id => Radiant::Config['default.page.filter'])]
    )
  end

end
