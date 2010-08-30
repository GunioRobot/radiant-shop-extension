require 'spec/spec_helper'

describe Shop::CategoriesController do
  dataset :shop_categories
  
  before(:each) do
    @shop_category = shop_categories(:bread)
    @shop_categories = [shop_categories(:bread), shop_categories(:salad)]
  end
  
  describe 'index' do
    it 'should expose categories list' do
      mock(ShopCategory).search(nil).returns(@shop_categories)
      get :index
      
      response.should be_success
    end
    
    it 'should return 404 if categories empty' do
      mock(ShopCategory).search(nil).returns([])
      get :index
      
      response.should render_template('site/not_found')
    end
  end
  
  describe '#show' do
    it 'should expose category' do
      mock(ShopCategory).find.returns(@shop_category)
      get :show
      
      response.should be_success
    end
    
    it 'should return 404 if product empty' do
      mock(ShopCategory).find
      get :show
      
      response.should render_template('site/not_found')
    end
    
    it 'should find a category by handle' do
      get :show, :handle => @shop_category.handle
      
      response.should be_success
    end
    
    it 'should not find a category with an invalid handle' do
      get :show, :handle => 'i-wont-exist'
      
      response.should render_template('site/not_found')
    end
  end
  
end
