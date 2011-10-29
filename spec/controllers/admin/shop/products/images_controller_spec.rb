require File.dirname(__FILE__) + "/../../../../spec_helper"

describe Admin::Shop::Products::ImagesController do

  dataset :users, :shop_products

  before(:each) do
    login_as  :admin

    @shop_product = shop_products(:soft_bread)
    @images = @shop_product.images

    mock(ShopProduct).find(@shop_product.id.to_s) { @shop_product }
  end

  describe '#index' do
    context 'product has no images' do
      before :each do
        stub(@shop_product).images { [] }
      end

      context 'html' do
        it 'should assign an error and redirect to edit_shop_product path' do
          get :index, :product_id => @shop_product.id
          response.should redirect_to(edit_admin_shop_product_path(@shop_product))
          flash.now[:error].should_not be_nil
        end
      end

      context 'js' do
        it 'should return an error string and unprocessable status' do
          get :index, :product_id => @shop_product.id, :format => 'js'
          response.should_not be_success
          response.body.should === 'This Product has no Images.'
        end
      end

      context 'json' do
        it 'should return a json error object and unprocessable status' do
          get :index, :product_id => @shop_product.id, :format => 'json'
          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'This Product has no Images.'
        end
      end
    end

    context 'product has images' do
      before :each do
        stub(@shop_product).images { @images }
      end

      context 'html' do
        before :each do
          get :index, :product_id => @shop_product.id
        end

        it 'should not assign an error and redirect to edit_shop_product path' do
          response.should redirect_to(edit_admin_shop_product_path(@shop_product))
          flash.now[:error].should be_nil
        end
      end

      context 'js' do
        before :each do
          get :index, :product_id => @shop_product.id, :format => 'js'
        end

        it 'should render the collection partial and success status' do
          response.should be_success
          response.should render_template('/admin/shop/products/edit/shared/_image')
        end
      end

      context 'json' do
        before :each do
          get :index, :product_id => @shop_product.id, :format => 'json'
        end

        it 'should return a json object of the array and success status' do
          response.should be_success
          response.body.should === @images.to_json
        end
      end
    end
  end

  describe '#sort' do

    before :each do
      @attachments = [
        'product_attachments[]=2',
        'product_attachments[]=1'
      ].join('&')
    end

    context 'could not sort' do
      before :each do
        stub(@shop_product).attachments.stub!.find('2').stub!.update_attributes!({ :position => 1 }) { raise ActiveRecord::RecordNotFound }

        stub(@shop_product).images { @images }
      end

      context 'html' do
        it 'should assign an error and redirect to edit_shop_product path' do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments
          flash.now[:error].should_not be_nil
          response.should redirect_to(edit_admin_shop_product_path(@shop_product))
        end
      end

      context 'js' do
        it 'should return an error string and unprocessable status' do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments, :format => 'js'
          response.should_not be_success
          response.body.should === 'Could not sort Images.'
        end
      end

      context 'json' do
        it 'should return a json error object and unprocessable status' do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments, :format => 'json'
          response.should_not be_success
          JSON.parse(response.body)['error'].should === 'Could not sort Images.'
        end
      end
    end

    context 'successfully sorted' do
      before :each do
        mock(Attachment).find('2').stub!.update_attributes!({:position => 1}) { true }
        mock(Attachment).find('1').stub!.update_attributes!({:position => 2}) { true }

        stub(@shop_product).images { @images }
      end

      context 'html' do
        before :each do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments
        end

        it 'should redirect to edit_shop_product path' do
          response.should redirect_to(edit_admin_shop_product_path(@shop_product))
        end

        it 'should have ordered the images based on input' do
          assigns(:images).first.should === '2'
          assigns(:images).last.should === '1'
        end
      end

      context 'js' do
        before :each do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments, :format => 'js'
        end

        it 'should render the collection partial and success status' do
          response.should be_success
          response.should render_template('/admin/shop/products/edit/shared/_image')
        end

        it 'should have ordered the images based on input' do
          assigns(:images).first.should === '2'
          assigns(:images).last.should === '1'
        end
      end

      context 'json' do
        before :each do
          put :sort, :product_id => @shop_product.id, :attachments => @attachments, :format => 'json'
        end

        it 'should return a json object of the array and success status' do
          response.should be_success
          response.body.should == @images.to_json
        end

        it 'should have ordered the images based on input' do
          assigns(:images).first.should === '2'
          assigns(:images).last.should === '1'
        end
      end
    end
  end

  describe '#create' do
    context 'new image' do
      context 'could not create image' do
        before :each do
          mock(Image).create!('FileObject') { raise 'Could not create Image' }
        end

        context 'html' do
          it 'should assign an error and redirect to edit_shop_product path' do
            post :create, :product_id => @shop_product.id, :image => 'FileObject'
            flash.now[:error].should_not be_nil
            response.should redirect_to(edit_admin_shop_product_path(@shop_product))
          end
        end

        context 'js' do
          it 'should return an error string and unprocessable status' do
            post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'js'
            response.should_not be_success
            response.body.should == 'Unable to create Image.'
          end
        end

        context 'json' do
          it 'should return a json error object and unprocessable status' do
            post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'json'
            response.should_not be_success
            JSON.parse(response.body)['error'].should === 'Unable to create Image.'
          end
        end

      end

      context 'successfully created image' do
        before :each do
          mock(Image).create!('FileObject') { @image }
        end

        context 'could not create attachment' do
          before :each do
            stub(Attachment).create!(anything) { raise ActiveRecord::RecordNotSaved }
          end

          context 'html' do
            it 'should assign an error and redirect to edit_shop_product path' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject'
              flash.now[:error].should_not be_nil
              response.should redirect_to(edit_admin_shop_product_path(@shop_product))
            end
          end

          context 'js' do
            it 'should return an error string and unprocessable status' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'js'
              response.should_not be_success
              response.body.should == 'Unable to create Image.'
            end
          end

          context 'json' do
            it 'should return a json error object and unprocessable status' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'json'
              response.should_not be_success
              JSON.parse(response.body)['error'].should === 'Unable to create Image.'
            end
          end
        end

        context 'successfully created attachment' do
          before :each do
            @attachment = Object.new
            mock(Attachment).create!(anything) { @attachment }
          end

          context 'html' do
            it 'should redirect to edit_shop_product path' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject'
              response.should redirect_to(edit_admin_shop_product_path(@shop_product))
            end
          end

          context 'js' do
            it 'should render the collection partial and success status' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'js'
              response.should be_success
              response.should render_template('/admin/shop/products/edit/shared/_image')
            end
          end

          context 'json' do
            it 'should return a json object of the array and success status' do
              post :create, :product_id => @shop_product.id, :image => 'FileObject', :format => 'json'
              response.should be_success
              response.body.should == @attachment.to_json
            end
          end
        end
      end
    end

    context 'existing image' do
      context 'could not find image' do
        before :each do
          mock(Image).find('1') { raise 'Could not find Image' }
        end

        context 'html' do
          it 'should assign an error and redirect to edit_shop_product path' do
            post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }
            flash.now[:error].should_not be_nil
            response.should redirect_to(edit_admin_shop_product_path(@shop_product))
          end
        end

        context 'js' do
          it 'should return an error string and unprocessable status' do
            post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'js'
            response.should_not be_success
            response.body.should == 'Unable to create Image.'
          end
        end

        context 'json' do
          it 'should return a json error object and unprocessable status' do
            post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'json'
            response.should_not be_success
            JSON.parse(response.body)['error'].should == 'Unable to create Image.'
          end
        end
      end

      context 'successfully found image' do
        before :each do
          mock(Image).find('1') { @image }
        end

        context 'could not create attachment' do
          before :each do
            stub(Attachment).create!(anything) { raise ActiveRecord::RecordNotSaved }
          end

          context 'html' do
            it 'should assign an error and redirect to edit_shop_product path' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }
              flash.now[:error].should_not be_nil
              response.should redirect_to(edit_admin_shop_product_path(@shop_product))
            end
          end

          context 'js' do
            it 'should return an error string and unprocessable status' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'js'
              response.should_not be_success
              response.body.should == 'Unable to create Image.'
            end
          end

          context 'json' do
            it 'should return a json error object and unprocessable status' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'json'
              response.should_not be_success
              JSON.parse(response.body)['error'].should == 'Unable to create Image.'
            end
          end
        end

        context 'successfully created attachment' do
          before :each do
            @attachment = Object.new
            stub(Attachment).create!(anything) { @attachment }
          end

          context 'html' do
            it 'should redirect to edit_shop_product path' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }
              response.should redirect_to(edit_admin_shop_product_path(@shop_product))
            end
          end

          context 'js' do
            it 'should render the collection partial and success status' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'js'
              response.should be_success
              response.should render_template('/admin/shop/products/edit/shared/_image')
            end
          end

          context 'json' do
            it 'should return a json object of the array and success status' do
              post :create, :product_id => @shop_product.id, :attachment => { :image_id => '1' }, :format => 'json'
              response.should be_success
              response.body.should == @attachment.to_json
            end
          end
        end
      end
    end
  end

  describe '#destroy' do
    context 'Attachment does not exist' do
      # Resource controller handles this
    end
    context 'Attachment exists' do
      before :each do
        mock(Attachment).find('1') { @image }
        stub(@image).id { 1 }
      end
      context 'could not destroy attachment' do
        before :each do
          stub(@image).destroy { raise 'Could not destroy attachment' }
          stub(@image).image { nil }
        end

        context 'html' do
          it 'should assign an error and redirect to edit_shop_product path' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id
            flash.now[:error].should_not be_nil
            response.should render_template(:remove)
          end
        end

        context 'js' do
          it 'should return an error string and unprocessable status' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id, :format => 'js'
            response.should_not be_success
            response.body.should == 'Unable to delete Image.'
          end
        end

        context 'json' do
          it 'should return a json error object and unprocessable status' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id, :format => 'json'
            response.should_not be_success
            JSON.parse(response.body)['error'].should === 'Unable to delete Image.'
          end
        end
      end
      context 'Successfully destroy attachment' do
        before :each do
          stub(@image).destroy { true }
          stub(@image).image { nil }
        end

        context 'html' do
          it 'should redirect to edit_shop_product path' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id
            response.should redirect_to(edit_admin_shop_product_path(@shop_product))
          end
        end

        context 'js' do
          it 'should render the collection partial and success status' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id, :format => 'js'
            response.should be_success
            response.should render_template('/admin/shop/products/edit/shared/_image')
          end
        end

        context 'json' do
          it 'should return a json object of the array and success status' do
            delete :destroy, :id => @image.id, :product_id => @shop_product.id, :format => 'json'
            response.should be_success
            JSON.parse(response.body)['notice'].should === 'Image deleted successfully.'
          end
        end
      end
    end
  end

end
