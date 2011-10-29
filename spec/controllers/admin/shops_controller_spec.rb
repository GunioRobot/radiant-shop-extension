require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ShopsController do
  dataset :users

  before :each do
    login_as :admin
  end

  describe '#index' do

    it 'should redirect to shop products' do
      get :index

      response.should redirect_to(admin_shop_products_path)
    end
  end

end
