require File.dirname(__FILE__) + "/../../../spec_helper"

#
# Tests for Page extensions
#
describe Shop::Models::Page do

  dataset :pages, :shop_categories, :shop_products

  before :each do
    @page = pages(:home)
  end

  context 'relationships' do

    describe 'belongs_to :shop_category' do
      it 'should accept and return a shop_category object' do
        @shop_category = shop_categories(:bread)

        @page.shop_category = @shop_category

        @page.shop_category.should === @shop_category
      end
    end

    describe 'belongs_to :shop_product' do
      it 'should accept and return a shop_product object' do
        @shop_product = shop_products(:warm_bread)

        @page.shop_product = @shop_product

        @page.shop_product.should === @shop_product
      end
    end

  end

end