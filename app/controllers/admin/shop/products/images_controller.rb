class Admin::Shop::Products::ImagesController < Admin::ResourceController

  model_class Attachment

  # GET /admin/shop/products/1/images
  # GET /admin/shop/products/1/images.js
  # GET /admin/shop/products/1/images.json                        AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    error = 'This Product has no Images.'

    @shop_product = ShopProduct.find(params[:product_id])

    unless @shop_product.images.empty?
      respond_to do |format|
        format.html { redirect_to edit_admin_shop_product_path(@shop_product) }
        format.js   { render :partial => '/admin/shop/products/edit/shared/image', :collection => @shop_product.images }
        format.json { render :json    => @shop_product.images.to_json }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = error
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :text    => error, :status => :unprocessable_entity }
        format.json { render :json    => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/shop/products/1/images/sort
  # PUT /admin/shop/products/1/images/sort.js
  # PUT /admin/shop/products/1/images/sort.json                   AJAX and HTML
  #----------------------------------------------------------------------------
  def sort
    notice = 'Successfully sorted Images.'
    error  = 'Could not sort Images.'
    begin
      @shop_product = ShopProduct.find(params[:product_id])

      @images = CGI::parse(params[:attachments])['product_attachments[]']
      @images.each_with_index do |id, index|
        Attachment.find(id).update_attributes!({ :position => index+1 })
      end

      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :partial => '/admin/shop/products/edit/shared/image', :collection => @shop_product.images }
        format.json { render :json    => @shop_product.images.to_json }
      end
    rescue
      respond_to do |format|
        format.html {
          flash[:error] = error
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :text  => error, :status => :unprocessable_entity }
        format.json { render :json  => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # POST /admin/shop/products/1/images
  # POST /admin/shop/products/1/images.js
  # POST /admin/shop/products/1/images.json                       AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    notice = 'Successfully created Image.'
    error  = 'Unable to create Image.'

    begin
      @shop_product = ShopProduct.find(params[:product_id])

      if params[:image]
        @image = Image.create!(params[:image])
      elsif params[:attachment]
        @image = Image.find(params[:attachment][:image_id])
      end

      @attachment = Attachment.create!(:image => @image, :page => @shop_product.page)

      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :partial => '/admin/shop/products/edit/shared/image', :locals => { :image => @attachment } }
        format.json { render :json    => @attachment.to_json  }
      end
    rescue
      respond_to do |format|
        format.html {
          flash[:error] = error
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :text  => error, :status => :unprocessable_entity }
        format.json { render :json  => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/shop/products/1/images/1
  # DELETE /admin/shop/products/1/images/1.js
  # DELETE /admin/shop/products/1/images/1.json                   AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    notice = 'Image deleted successfully.'
    error  = 'Unable to delete Image.'
    begin
      @shop_product = ShopProduct.find(params[:product_id])
      @image = @attachment.image
      @attachment.destroy

      respond_to do |format|
        format.html {
          redirect_to edit_admin_shop_product_path(@shop_product)
        }
        format.js   { render :partial => '/admin/shop/products/edit/shared/image', :locals => { :excerpt => @image } }
        format.json { render :json    => { :notice => notice }, :status => :ok }
      end
    rescue
      respond_to do |format|
        format.html {
          flash[:error] = error
          render :remove
        }
        format.js   { render :text    => error, :status => :unprocessable_entity }
        format.json { render :json    => { :error => error }, :status => :unprocessable_entity }
      end
    end
  end

end