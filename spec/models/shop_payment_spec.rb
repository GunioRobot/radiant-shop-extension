require File.dirname(__FILE__) + "/../spec_helper"

describe ShopPayment do

  dataset :shop_orders, :shop_payments

  describe 'relationships' do
    context 'order' do
      before :each do
        @order = shop_orders(:several_items)
      end
      it 'should belong to one' do
        @payment = shop_payments(:visa)
        @payment.order.should === @order
      end
    end
  end

end