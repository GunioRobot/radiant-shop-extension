require File.dirname(__FILE__) + "/../spec_helper"

describe ShopShipping do

  dataset :shop_addresses, :shop_orders

  describe 'scope' do
    before :each do
      @address = ShopShipping.new
    end

    it 'should have a of_type of shipping' do
      @address.of_type.should == 'shipping'
    end

  end

  describe 'validations' do
    before :each do
      @address = shop_shippings(:order_shipping)
    end
    context 'email' do
      it 'should not require' do
        @address.email = nil
        @address.valid?.should be_true
      end
    end
  end

end