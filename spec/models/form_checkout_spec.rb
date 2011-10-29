require File.dirname(__FILE__) + "/../spec_helper"

describe FormCheckout do

  dataset :shop_orders, :pages, :forms, :shop_addresses, :shop_customers

  before :each do
    mock_page_with_request_and_data
  end

  describe '#create' do
    context 'gateway' do
      context 'configured correctly' do
        before :each do
          login_as :customer
          @order = shop_orders(:several_items)

          mock_valid_form_checkout_request
        end

        it 'should assign ActiveMerchant to testing mode' do
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          @checkout.create

          ActiveMerchant::Billing::Base.mode.should === :test
        end

        it 'should return true for payment results' do
          mock.instance_of(ActiveMerchant::Billing::CreditCard).valid? { true }
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create

          result[:gateway].should be_true
          result[:card].should    be_true
          result[:payment].should be_true
          result[:message].should === "Bogus Gateway: Forced success"
        end

        it 'should assign a payment object' do
          mock.instance_of(ActiveMerchant::Billing::CreditCard).valid? { true }
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create

          @order.payment.card_number.should   === "XXXX-XXXX-XXXX-1"
          @order.payment.card_type.should     === @data[:credit_card][:type]
          @order.payment.amount.should        === @order.price
        end

        it 'should assign the note' do
          mock.instance_of(ActiveMerchant::Billing::CreditCard).valid? { true }
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create

          shop_orders(:several_items).notes.should === 'some note'
        end

        it 'should assign session shop_order to nil' do
          mock.instance_of(ActiveMerchant::Billing::CreditCard).valid? { true }
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create
        end
      end

      context 'no billing address sent' do
        before :each do
          login_as :customer
          @order = shop_orders(:empty)
          mock_valid_form_checkout_request
        end

        it 'should return the standard response' do
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create

          result[:gateway].should be_nil
          result[:payment].should be_nil
          result[:card].should    be_nil
          result[:message].should === "Billing Address has not been set"
        end
      end

      context 'configured incorrectly' do
        before :each do
          login_as :customer
          @order = shop_orders(:several_items)

          mock_valid_form_checkout_request
        end
        context 'no gateway' do
          it 'should return gateway false' do
            @form[:extensions][:bogus_checkout][:gateway] = nil

            @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
            result = @checkout.create

            result[:gateway].should be_false
            result[:card].should    be_nil
            result[:payment].should be_nil
            result[:message].should === "Payment gateway has not been configured"

            @order.payment.should   be_nil
          end
        end

        context 'no card' do
          it 'should return card and payment false' do
            @data[:credit_card] = nil

            @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
            result = @checkout.create

            result[:gateway].should be_true
            result[:card].should    be_nil
            result[:payment].should be_nil
            result[:message].should === "Credit card details were not sent"

            @order.payment.should   be_nil
          end
        end

        context 'invalid card' do
          it 'should return card and payment false' do
            @card = ActiveMerchant::Billing::CreditCard.new
            stub(@card).valid? { false }

            mock.instance_of(ActiveMerchant::Billing::CreditCard) { @card }

            @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
            result = @checkout.create

            result[:gateway].should be_true
            result[:card].should    be_false
            result[:payment].should be_nil
            result[:message].should === "Type is not the correct card type"

            @order.payment.should   be_nil
          end
        end
      end
    end

    context 'result_extension' do
      before :each do
        mock.instance_of(ActiveMerchant::Billing::CreditCard).valid? { true }
      end

      context 'mail configured' do
        before :each do
          login_as :customer
          @order = shop_orders(:several_items)

          mock_valid_form_checkout_request
        end
        context 'payment successful' do
          before :each do
            @checkout = FormCheckout.new(@form,@page,@form[:extensions][:bogus_checkout])
          end
          it 'should configure order and invoice to be sent' do
            @config = @form[:extensions][:bogus_checkout][:extensions]
            @config[:invoice].merge!({
              :to => @order.billing.email
            })

            @form_mail = Object.new
            mock(@form_mail).create.times(2) { true }
            mock(FormMail).new(@form,@page,@config[:order]) { @form_mail }
            mock(FormMail).new(@form,@page,@config[:invoice]) { @form_mail }

            @checkout.create
          end
        end

        context 'payment unsuccesful' do
          it 'should not configure mail to be sent' do
            @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
            stub(@checkout).success? { false }
            @checkout.create

            @form[:extensions][:mail].should be_nil
          end
        end
      end

      context 'mail not configured' do
        before :each do
          login_as :customer
          @order = shop_orders(:several_items)

          mock_valid_form_checkout_request
          @form[:extensions][:bogus_checkout][:extensions] = nil
        end
        it 'should not configure mail to be sent' do
          @checkout = FormCheckout.new(@form, @page, @form[:extensions][:bogus_checkout])
          result = @checkout.create

          do_not_allow(FormMail).new(@form,@page,anything)
        end
      end
    end
  end
end