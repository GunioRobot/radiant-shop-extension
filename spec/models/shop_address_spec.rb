require File.dirname(__FILE__) + "/../spec_helper"

describe ShopAddress do

  dataset :shop_addresses, :shop_orders

  describe 'validations' do
    before :each do
      @address = shop_billings(:order_billing)
    end
    context 'unit' do
      it 'should not require' do
        @address.unit = nil
        @address.valid?.should be_true
      end
    end
    context 'name' do
      it 'should require' do
        @address.name = nil
        @address.valid?.should be_false
      end
    end
    context 'street_1' do
      it 'should require' do
        @address.street_1 = nil
        @address.valid?.should be_false
      end
    end
    context 'street_2' do
      it 'should not require' do
        @address.street_2 = nil
        @address.valid?.should be_true
      end
    end
    context 'city' do
      it 'should require' do
        @address.city = nil
        @address.valid?.should be_false
      end
    end
    context 'postcode' do
      it 'should require' do
        @address.postcode = nil
        @address.valid?.should be_false
      end
    end
    context 'state' do
      it 'should require' do
        @address.state = nil
        @address.valid?.should be_false
      end
    end
    context 'country' do
      it 'should require' do
        @address.country = nil
        @address.valid?.should be_false
      end
    end
    context 'phone' do
      it 'should not require' do
        @address.phone = nil
        @address.valid?.should be_true
      end
    end
    context 'company' do
      it 'should not require' do
        @address.company = nil
        @address.valid?.should be_true
      end
    end
  end

end
