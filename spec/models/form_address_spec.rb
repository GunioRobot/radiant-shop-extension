require File.dirname(__FILE__) + "/../spec_helper"

describe FormAddress do

  dataset :shop_orders, :pages, :forms, :shop_addresses, :shop_customers

  before :each do
    mock_page_with_request_and_data
  end
  describe '#create' do
    context 'addresses' do
      context 'sending ids with user logged in' do
        before :each do
          login_as :customer # Will have existing addresses due to several_items
          @order = shop_orders(:one_item)
          mock_valid_form_address_request
        end

        context 'both billing and shipping' do
          it 'should assign that address to the order billing and shipping' do
            @data[:billing]   = shop_orders(:several_items).billing.attributes.reject{ |k,v| k == 'id' }
            @data[:shipping]  = shop_orders(:several_items).shipping.attributes.reject{ |k,v| k == 'id' }

            @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
            result = @address.create

            shop_orders(:one_item).billing.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }.should  == shop_billings(:order_billing).attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }
            shop_orders(:one_item).shipping.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }.should == shop_shippings(:order_shipping).attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }

            result[:billing].should  === shop_orders(:one_item).billing.id
            result[:shipping].should === shop_orders(:one_item).shipping.id
          end
        end

        context 'just billing' do
          it 'should assign shipping to be billing' do
            # Set the order to have no shipping address
            @data[:shipping] = {}
            @form[:extensions][:address] = { :billing => true }

            @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
            result = @address.create

            shop_orders(:one_item).billing.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }.should  === shop_billings(:order_billing).attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }
            shop_orders(:one_item).shipping.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }.should === shop_shippings(:order_shipping).attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }
          end
        end
      end

      context 'updating existing addresses' do
        before :each do
          login_as :customer
          @order = shop_orders(:several_items)
          mock_valid_form_address_request
        end
        it 'should keep them assigned and update them' do
          @data[:billing]   = { :name => 'new billing' }
          @data[:shipping]  = { :name => 'new shipping' }

          @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
          result = @address.create

          shop_billings(:order_billing).name.should  === 'new billing'
          shop_shippings(:order_shipping).name.should === 'new shipping'
        end
      end

      context 'new addresses' do
        before :each do
          login_as :customer
          @order = shop_orders(:one_item)
          mock_valid_form_address_request

          @data[:billing][:id]  = nil
          @data[:shipping][:id] = nil
        end

        context 'both billing and shipping sent' do
          it 'should create new addresses' do
            @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
            result = @address.create

            shop_orders(:one_item).billing.name.should  === @data[:billing][:name]
            shop_orders(:one_item).shipping.name.should === @data[:shipping][:name]

            result[:billing].should  === shop_orders(:one_item).billing.id
            result[:shipping].should === shop_orders(:one_item).shipping.id
          end
        end

        context 'only billing sent' do
          it 'should copy billing to shipping' do
            @data[:shipping] = {}

            @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
            result = @address.create

            shop_orders(:one_item).billing.name.should  === @data[:billing][:name]
            shop_orders(:one_item).shipping.name.should === @data[:billing][:name]

            result[:billing].should  === shop_orders(:one_item).billing.id
            result[:shipping].should === shop_orders(:one_item).shipping.id
          end
        end

        context 'billing sent with same shipping' do
          it 'should copy billing to shipping' do
            @data[:shipping] = @data[:billing]

            @address = FormAddress.new(@form, @page, @form[:extensions][:addresses])
            result = @address.create

            shop_orders(:one_item).shipping.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }.should === shop_orders(:one_item).billing.attributes.reject{ |k,v| k == 'id' || k = 'addressable_id' }

            result[:billing].should  === shop_orders(:one_item).billing.id
            result[:shipping].should === shop_orders(:one_item).shipping.id
          end
        end
      end
    end
  end

end