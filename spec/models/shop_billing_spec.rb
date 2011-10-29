require File.dirname(__FILE__) + "/../spec_helper"

describe ShopBilling do

  dataset :shop_addresses, :shop_orders

  describe 'scope' do
    before :each do
      @address = ShopBilling.new
    end

    it 'should have a of_type of billing' do
      @address.of_type.should == 'billing'
    end

  end

  describe 'validations' do
    before :each do
      @address = shop_billings(:order_billing)
    end
    context 'email' do
      it 'should require' do
        @address.email = nil
        @address.valid?.should be_false
      end
    end
  end

end