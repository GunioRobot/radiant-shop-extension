require File.dirname(__FILE__) + "/../../../spec_helper"

describe Admin::Shop::ProductsController do

  dataset :users, :shop_categories, :shop_products

  before(:each) do
    login_as  :admin

    @product  = shop_products(:crusty_bread)
    @products = @product.category.products
  end

  describe '#index' do
    context 'html' do
      it 'should render index' do
        get :index

        response.should render_template(:index)
      end

      it 'should also assign shop_categories' do
        get :index

        assigns(:shop_categories).should == ShopCategory.all
      end
    end

    context 'js' do
      it 'should render the collection partial and success status' do
        get :index, :format => 'js'

        response.should be_success
        response.should render_template('/admin/shop/products/index/_product')
      end
    end

    context 'json' do
      it 'should return a json object of the array and success status' do
        get :index, :format => 'json'

        response.should be_success
        response.body.should === assigns(:shop_products).to_json
      end
    end

  end

  describe '#sort' do
    before :each do
      @params = [
        "category_#{@product.category.id}_products[]=2",
        "category_#{@product.category.id}_products[]=1",
        "category_#{@product.category.id}_products[]=0"
      ].join('&')
    end

    context 'products are not passed' do
      context 'html' do
        it 'should assign an error and redirect to admin_shop_products_path path' do
          put :sort, :category_id => @product.category.id

          flash.now[:error].should_not be_nil
          response.should redirect_to(admin_shop_products_path)
        end
      end

      context 'js' do
        it 'should return an error string and failure status' do
          put :sort, :category_id => @product.category.id, :format => 'js'

          response.should_not be_success
          response.body.should === 'Could not sort Products.'
        end
      end

      context 'json' do
        it 'should return a json error object and failure status' do
          put :sort, :category_id => @product.category.id, :format => 'json'

          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'Could not sort Products.'
        end
      end
    end

    context 'products are passed' do
      context 'could not sort' do
        before :each do
          mock(ShopProduct).sort(@product.category.id.to_s, anything) { raise ActiveRecord::RecordNotFound }
        end

        context 'html' do
          it 'should assign an error and redirect to admin_shop_products_path path' do
            put :sort, :products => @params, :category_id => @product.category.id
            flash.now[:error].should === 'Could not sort Products.'
            response.should redirect_to(admin_shop_products_path)
          end
        end

        context 'js' do
          it 'should return an error string and failure status' do
            put :sort, :products => @params, :category_id => @product.category.id, :format => 'js'
            response.should_not be_success
            response.body.should === 'Could not sort Products.'
          end
        end

        context 'json' do
          it 'should return a json error object and failure status' do
            put :sort, :products => @params, :category_id => @product.category.id, :format => 'json'
            response.should_not be_success
            JSON.parse(response.body)['error'].should === 'Could not sort Products.'
          end
        end
      end

      context 'successfully sorted' do
        before :each do
          mock(ShopProduct).sort(@product.category.id.to_s, anything) { true }
        end

        context 'html' do
          it 'should redirect to admin_shop_products_path path' do
            put :sort, :products => @params, :category_id => @product.category.id
            response.should redirect_to(admin_shop_products_path)
          end
        end

        context 'js' do
          it 'should return success string and success status' do
            put :sort, :products => @params, :category_id => @product.category.id, :format => 'js'

            response.should be_success
            response.body.should === 'Products successfully sorted.'
          end
        end

        context 'json' do
          it 'should return a json success object and success status' do
            put :sort, :products => @params, :category_id => @product.category.id, :format => 'json'

            response.should be_success
            JSON.parse(response.body)['notice'].should === 'Products successfully sorted.'
          end
        end
      end
    end
  end

  describe '#create' do
    context 'product could not be created' do
      context 'html' do
        it 'should assign a flash error and render new' do
          post :create, :shop_product => {}

          response.should render_template(:new)
          flash.now[:error].should === 'Could not create Product.'
        end
      end

      context 'js' do
        it 'should return error notice and failure status' do
          post :create, :shop_product => {}, :format => 'js'

          response.body.should === 'Could not create Product.'
          response.should_not be_success
        end
      end

      context 'json' do
        it 'should return an error json object and failure status' do
          post :create, :shop_product => {}, :format => 'json'

          JSON.parse(response.body)['error'].should === 'Could not create Product.'
          response.should_not be_success
        end
      end
    end

    context 'product successfully created' do
      before :each do
        @params = {
          :page_attributes => {
            :title     => 'name',
            :parent_id => @product.category.page.id,
            :parts_attributes => [{
              :name    => 'description',
              :content => '*name*'
            }]
          },
          :price => 11.11
        }
      end
      context 'html' do
        context 'not continue' do
          it 'should redirect to edit_shop_product path' do
            post :create, :shop_product => @params

            response.should redirect_to(admin_shop_products_path)
          end
        end
        context 'continue' do
          it 'should redirect to edit_shop_product path' do
            post :create, :shop_product => @params, :continue => true

            response.should redirect_to(edit_admin_shop_product_path(assigns(:shop_product)))
          end
        end
      end

      context 'js' do
        it 'should render the collection partial and success status' do
          post :create, :shop_product => @params, :format => 'js'

          response.should be_success
          response.should render_template('/admin/shop/products/index/_product')
        end
      end

      context 'json' do
        it 'should render the json object and redirect to json show' do
          post :create ,:shop_product => @params, :format => 'json'

          response.should be_success
          response.body.should === assigns(:shop_product).to_json
        end
      end
    end
  end

  describe '#update' do
    context 'could not update' do
      context 'html' do
        it 'should assign a flash error and render edit' do
          put :update, :id => @product.id, :shop_product => { :title => 'failure' }

          response.should render_template(:edit)
          flash.now[:error].should === 'Could not update Product.'
        end
      end

      context 'js' do
        it 'should render the error and failure status' do
          put :update, :id => @product.id, :shop_product => { :title => 'failure' }, :format => 'js'
          response.should_not be_success
          response.body.should === 'Could not update Product.'
        end
      end

      context 'json' do
        it 'should assign an error json object and failure status' do
          put :update, :id => @product.id, :shop_product => { :title => 'failure' }, :format => 'json'
          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'Could not update Product.'
        end
      end
    end

    context 'successfully updated' do
      context 'html' do
        context 'not continue' do
          it 'should redirect to edit_shop_product path' do
            put :update, :id => @product.id, :shop_product => { :page_attributes => { :title => 'success', :parent_id => @product.category.page.id } }
            response.should redirect_to(admin_shop_products_path)
          end
        end
        context 'continue' do
          it 'should redirect to edit_shop_product path' do
            put :update, :id => @product.id, :shop_product => { :page_attributes => { :title => 'success', :parent_id => @product.category.page.id } }, :continue => true
            response.should redirect_to(edit_admin_shop_product_path(assigns(:shop_product)))
          end
        end
      end

      context 'js' do
        it 'should render the partial and success status' do
          put :update, :id => @product.id, :shop_product => { :page_attributes => { :title => 'success', :parent_id => @product.category.page.id } }, :format => 'js'
          response.should be_success
          response.should render_template('/admin/shop/products/index/_product')
        end
      end

      context 'json' do
        it 'should assign the json object and success status' do
          put :update, :id => @product.id, :shop_product => { :page_attributes => { :title => 'success', :parent_id => @product.category.page.id } }, :format => 'json'

          response.should be_success
          response.body.should === assigns(:shop_product).to_json(ShopProduct.params)
        end
      end
    end
  end

  describe '#destroy' do
    context 'product successfully destroyed' do

      context 'html' do
        it 'should redirect to shop_products path' do
          delete :destroy, :id => @product.id

          response.should redirect_to(admin_shop_products_path)
        end
      end

      context 'js' do
        it 'should render success message and success status' do
          delete :destroy, :id => @product.id, :format => 'js'

          response.body.should === 'Product deleted successfully.'
          response.should be_success
        end
      end

      context 'json' do
        it 'should return a success json object and success status' do
          delete :destroy, :id => @product.id, :format => 'json'

          JSON.parse(response.body)['notice'].should === 'Product deleted successfully.'
          response.should be_success
        end
      end
    end
  end

end
