require File.dirname(__FILE__) + "/../spec_helper"

describe ShopCustomer do

  dataset :shop_customers, :shop_orders

  describe 'relationships' do
    before :each do
      @customer = shop_customers(:customer)
    end

    context 'orders' do
      before :each do
        @order = shop_orders(:empty)
      end
      it 'should have many' do
        @customer.orders << @order
        @customer.orders.include?(@order).should === true
      end
    end

    context 'billing addresses' do
      before :each do
        @order = shop_orders(:several_items)
      end
      it 'should have many through orders' do
        pending
        @customer.orders << @order
        @customer.billings.include?(@order.billing).should === true
      end
    end

    context 'shipping addresses' do
      before :each do
        @order = shop_orders(:several_items)
      end
      it 'should have many through orders' do
        pending
        @customer.orders << @order
        @customer.shippings.include?(@order.shipping).should === true
      end
    end
  end

  describe 'attributes' do
    before :each do
      @customer = shop_customers(:customer)
    end
    context 'nested order' do
      it 'should allowing nesting an order' do
        @customer.update_attributes({
          :orders => [ ShopOrder.create({ :status => 'nested' }) ]
        })
        @customer.orders.last.status.should === 'nested'
      end
    end
  end

  describe '#first_name' do
    before :each do
      @customer = ShopCustomer.new
    end
    context '1 word' do
      it 'should return the name' do
        @customer.name = 'Dirk'
        @customer.first_name.should === 'Dirk'
      end
    end
    context '2 words' do
      it 'should return the first name' do
        @customer.name = 'Dirk Kelly'
        @customer.first_name.should === 'Dirk'
      end
    end
    context '3 words' do
      it 'should return all but last name' do
        @customer.name = 'Mr. Dirk Kelly'
        @customer.first_name.should === 'Mr. Dirk'
      end
    end
  end

  describe '#last_name' do
    before :each do
      @customer = ShopCustomer.new
    end
    context '1 word' do
      it 'should return nothing' do
        @customer.name = 'Dirk'
        @customer.last_name.should === ''
      end
    end
    context '2 words' do
      it 'should return the last name' do
        @customer.name = 'Dirk Kelly'
        @customer.last_name.should === 'Kelly'
      end
    end
    context '3 words' do
      it 'should return the last name' do
        @customer.name = 'Mr. Dirk Kelly'
        @customer.last_name.should === 'Kelly'
      end
    end
  end

end