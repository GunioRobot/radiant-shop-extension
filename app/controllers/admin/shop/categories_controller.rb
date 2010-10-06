class Admin::Shop::CategoriesController < Admin::ResourceController
    
  model_class ShopCategory
  
  before_filter :config_global
  before_filter :config_new,    :only => [ :new, :create ]
  before_filter :config_edit,   :only => [ :edit, :update ]
  before_filter :assets_global
  
  before_filter :set_layouts_and_page,   :only => [ :new ]
  
  # GET /admin/shop/products/categories
  # GET /admin/shop/products/categories.js
  # GET /admin/shop/products/categories.json                      AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    respond_to do |format|
      format.html { redirect_to admin_shop_products_path }
      format.js   { render :partial => '/admin/shop/categories/index/category', :collection => @shop_categories }
      format.json { render :json    => @shop_categories.to_json(ShopCategory.params) }
    end
  end
  
  # GET /admin/shop/products/categories/1/products
  # GET /admin/shop/products/categories/1/products.js
  # GET /admin/shop/products/categories/1/products.json           AJAX and HTML
  #----------------------------------------------------------------------------
  def products
    @shop_category = ShopCategory.find(params[:id])
    @shop_products = @shop_category.products
    
    respond_to do |format|
      format.html { render :template  => '/admin/shop/products/index' }
      format.js   { render :partial   => '/admin/shop/products/index/product', :collection => @shop_products }
      format.json { render :json      => @shop_products.to_json(ShopProduct.params) }
    end
  end
  
  # PUT /admin/shop/categories/sort
  # PUT /admin/shop/categories/sort.js
  # PUT /admin/shop/categories/sort.json                          AJAX and HTML
  #----------------------------------------------------------------------------
  def sort
    notice  = 'Categories successfully sorted.'
    error   = 'Could not sort Categories.'
    
    begin  
      @shop_categories = CGI::parse(params[:categories])["categories[]"]

      @shop_categories.each_with_index do |id, index|
        ShopCategory.find(id).page.update_attributes!(
          :position  => index+1
        )
      end
      
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
  
  # POST /admin/shop/products/categories
  # POST /admin/shop/products/categories.js
  # POST /admin/shop/products/categories.json                     AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    notice = 'Category created successfully.'
    error = 'Could not create Category.'
    
    @shop_category.attributes = params[:shop_category]
    
    begin
      @shop_category.save!
      
      respond_to do |format|
        format.html {
          redirect_to [:edit_admin, @shop_category] if params[:continue]
          redirect_to admin_shop_categories_path unless params[:continue]
        }
        format.js   { render :partial => '/admin/shop/categories/index/category', :locals => { :product => @shop_category } }
        format.json { render :json    => @shop_category.to_json(ShopCategory.params) }
      end
    rescue Exception => e
      raise e.inspect
      respond_to do |format|
        format.html { 
          flash[:error] = error
          render :new
        }
        format.js   { render :text  => error, :status => :unprocessable_entity }
        format.json { render :json  => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/shop/products/categories/1
  # PUT /admin/shop/products/categories/1.js
  # PUT /admin/shop/products/categories/1.json                    AJAX and HTML
  #----------------------------------------------------------------------------
  def update
    notice = 'Category updated successfully.'
    error = 'Could not update Category.'
    
    begin
      @shop_category.update_attributes!(params[:shop_category])
      
      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_category_path(@shop_category) if params[:continue]
          redirect_to admin_shop_categories_path unless params[:continue]
        }
        format.js   { render :partial => '/admin/shop/categories/index/category', :locals => { :product => @shop_category } }
        format.json { render :json    => @shop_category.to_json(ShopCategory.params) }
      end
    rescue
      respond_to do |format|
        format.html { 
          flash[:error] = error
          render :edit
        }
        format.js   { render :text  => error, :status => :unprocessable_entity }
        format.json { render :json  => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/shop/products/categories/1
  # DELETE /admin/shop/products/categories/1.js
  # DELETE /admin/shop/products/categories/1.json                 AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    notice = 'Category deleted successfully.'
    error = 'Could not delete Category.'
    
    begin
      @shop_category.destroy
      
      respond_to do |format|
        format.html {
          redirect_to admin_shop_categories_path
        }
        format.js   { render :text  => notice, :status => :ok }
        format.json { render :json  => { :notice => notice }, :status => :ok }
      end
    rescue
      respond_to do |format|
        format.html {
          flash[:error] = error
          render :remove
        }
        format.js   { render :text  => error, :status => :unprocessable_entity }
        format.json { render :json  => { :error => error }, :status => :unprocessable_entity }
      end
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
    
    @meta     << 'handle'
    @meta     << 'layouts'
    @meta     << 'page'
    
    @parts    << 'description'
  end
  
  def config_new
  end
  
  def config_edit
  end
  
  def assets_global
    include_stylesheet 'admin/extensions/shop/edit'
  end
  
  def set_layouts_and_page
    @shop_category.page = Page.new(
      :layout_id  => Layout.find_by_name(Radiant::Config['shop.layout_category']).id,
      :parent_id  => Radiant::Config['shop.root_page_id'],
      :parts      => [PagePart.new]
    )
    @shop_category.product_layout = Layout.find_by_name(Radiant::Config['shop.product_layout'])
  end
  
end