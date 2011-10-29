require File.dirname(__FILE__) + "/../../../spec_helper"

describe Admin::Shop::CategoriesController do

  dataset :users, :shop_categories, :shop_products, :pages

  before(:each) do
    login_as  :admin

    @category = shop_categories(:bread)
    @products = @category.products
  end

  describe '#index' do
    context 'html' do
      it 'should redirect to shop_products path' do
        get :index

        flash.now[:error].should be_nil
        response.should redirect_to(admin_shop_products_path)
      end
    end

    context 'js' do
      it 'should render the collection partial and success status' do
        get :index, :format => 'js'

        response.should be_success
        response.should render_template('/admin/shop/categories/index/_category')
      end
    end

    context 'json' do
      it 'should return a json object of the array and success status' do
        get :index, :format => 'json'

        response.should be_success
        response.body.should === assigns(:shop_categories).to_json
      end
    end

  end

  describe '#sort' do
    before :each do
      @params = [
        "categories[]=2",
        "categories[]=1"
      ].join('&')
    end

    context 'categories are not passed' do
      context 'html' do
        it 'should assign an error and redirect to admin_shop_products_path path' do
          put :sort

          flash.now[:error].should_not be_nil
          response.should redirect_to(admin_shop_products_path)
        end
      end

      context 'js' do
        it 'should return an error string and failure status' do
          put :sort, :format => 'js'

          response.should_not be_success
          response.body.should === 'Could not sort Categories.'
        end
      end

      context 'json' do
        it 'should return a json error object and failure status' do
          put :sort, :format => 'json'

          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'Could not sort Categories.'
        end
      end
    end

    context 'categories are passed' do
      context 'could not sort' do
        before :each do
          mock(ShopCategory).sort(anything) { raise ActiveRecord::RecordNotFound }
        end

        context 'html' do
          it 'should assign an error and redirect to admin_shop_products_path path' do
            put :sort, :categories => @params

            flash.now[:error].should === 'Could not sort Categories.'
            response.should redirect_to(admin_shop_products_path)
          end
        end

        context 'js' do
          it 'should return an error string and failure status' do
            put :sort, :categories => @params, :format => 'js'

            response.should_not be_success
            response.body.should === 'Could not sort Categories.'
          end
        end

        context 'json' do
          it 'should return a json error object and failure status' do
            put :sort, :categories => @params, :format => 'json'

            response.should_not be_success
            JSON.parse(response.body)['error'].should === 'Could not sort Categories.'
          end
        end
      end

      context 'successfully sorted' do
        before :each do
          mock(ShopCategory).sort(anything) { true }
        end

        context 'html' do
          it 'should assign a notice and redirect to admin_shop_products_path path' do
            put :sort, :categories => @params

            flash.now[:error].should be_nil
            response.should redirect_to(admin_shop_products_path)
          end
        end

        context 'js' do
          it 'should return success string and success status' do
            put :sort, :categories => @params, :format => 'js'

            response.should be_success
            response.body.should === 'Categories successfully sorted.'
          end
        end

        context 'json' do
          it 'should return a json success object and success status' do
            put :sort, :categories => @params, :format => 'json'

            response.should be_success
            JSON.parse(response.body)['notice'].should === 'Categories successfully sorted.'
          end
        end
      end
    end
  end

  describe '#create' do
    context 'category could not be created' do
      context 'html' do
        it 'should assign a flash error and render new' do
          post :create, :shop_category => {}

          response.should render_template(:new)
          flash.now[:error].should === 'Could not create Category.'
        end
      end

      context 'js' do
        it 'should return error notice and failure status' do
          post :create, :shop_category => {}, :format => 'js'

          response.body.should === 'Could not create Category.'
          response.should_not be_success
        end
      end

      context 'json' do
        it 'should return an error json object and failure status' do
          post :create, :shop_category => {}, :format => 'json'

          JSON.parse(response.body)['error'].should === 'Could not create Category.'
          response.should_not be_success
        end
      end
    end

    context 'category successfully created' do
      before :each do
        @params = {
          :page_attributes => {
            :title     => 'name',
            :parent_id => pages(:home).id,
            :parts_attributes => [{
              :name    => 'description',
              :content => '*name*'
            }]
          }
        }
      end
      context 'html' do
        context 'not continue' do
          it 'should assign a notice and redirect to edit_shop_product path' do
            post :create, :shop_category => @params

            response.should redirect_to(admin_shop_categories_path)
          end
        end
        context 'continue' do
          it 'should assign a notice and redirect to edit_shop_product path' do
            post :create, :shop_category => @params, :continue => true

            response.should redirect_to(edit_admin_shop_category_path(assigns(:shop_category)))
          end
        end
      end

      context 'js' do
        it 'should render the collection partial and success status' do
          post :create, :shop_category => @params, :format => 'js'

          response.should be_success
          response.should render_template('/admin/shop/categories/index/_category')
        end
      end

      context 'json' do
        it 'should render the json object and redirect to json show' do
          post :create ,:shop_category => @params, :format => 'json'

          response.should be_success
          response.body.should === assigns(:shop_category).to_json
        end
      end
    end
  end

  describe '#update' do
    context 'could not update' do
      context 'html' do
        it 'should assign a flash error and render edit' do
          put :update, :id => @category.id, :shop_category => { :title => 'failure' }

          response.should render_template(:edit)
          flash.now[:error].should === 'Could not update Category.'
        end
      end

      context 'js' do
        it 'should render the error and failure status' do
          put :update, :id => @category.id, :shop_category => { :title => 'failure' }, :format => 'js'

          response.should_not be_success
          response.body.should === 'Could not update Category.'
        end
      end

      context 'json' do
        it 'should assign an error json object and failure status' do
          put :update, :id => @category.id, :shop_category => { :title => 'failure' }, :format => 'json'

          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'Could not update Category.'
        end
      end
    end

    context 'successfully updated' do
      context 'html' do
        context 'not continue' do
          it 'should assign a notice and redirect to edit_shop_product path' do
            put :update, :id => @category.id, :shop_category => { :page_attributes => { :title => 'success' } }

            response.should redirect_to(admin_shop_categories_path)
          end
        end
        context 'continue' do
          it 'should assign a notice and redirect to edit_shop_product path' do
            put :update, :id => @category.id, :shop_category => { :page_attributes => { :title => 'success' } }, :continue => true

            response.should redirect_to(edit_admin_shop_category_path(assigns(:shop_category)))
          end
        end
      end

      context 'js' do
        it 'should render the partial and success status' do
          put :update, :id => @category.id, :shop_category => { :page_attributes => { :title => 'success' } }, :format => 'js'

          response.should be_success
          response.should render_template('/admin/shop/categories/index/_category')
        end
      end

      context 'json' do
        it 'should assign the json object and success status' do
          put :update, :id => @category.id, :shop_category => {}, :format => 'json'

          response.should be_success
          response.body.should === assigns(:shop_category).to_json
        end
      end
    end
  end

  describe '#destroy' do
    context 'product successfully destroyed' do
      context 'html' do
        it 'should assign a flash notice and redirect to shop_categories path' do
          delete :destroy, :id => @category.id

          response.should redirect_to(admin_shop_categories_path)
        end
      end

      context 'js' do
        it 'should render success message and success status' do
          delete :destroy, :id => @category.id, :format => 'js'

          response.body.should === 'Category deleted successfully.'
          response.should be_success
        end
      end

      context 'json' do
        it 'should return a success json object and success status' do
          delete :destroy, :id => @category.id, :format => 'json'

          JSON.parse(response.body)['notice'].should === 'Category deleted successfully.'
          response.should be_success
        end
      end
    end
  end

end
