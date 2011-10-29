require File.dirname(__FILE__) + "/../../../spec_helper"

#
# Tests for shop order tags module
#
describe Shop::Tags::Cart do

  dataset :pages, :tags, :shop_config, :shop_orders, :shop_payments

  it 'should describe these tags' do
    Shop::Tags::Cart.tags.sort.should == [
      'shop:cart',
      'shop:cart:forget',
      'shop:cart:if_cart',
      'shop:cart:unless_cart',
      'shop:cart:payment',
      'shop:cart:payment:if_paid',
      'shop:cart:payment:unless_paid',
      'shop:cart:payment:date',
      'shop:cart:id',
      'shop:cart:status',
      'shop:cart:quantity',
      'shop:cart:weight',
      'shop:cart:notes',
      'shop:cart:price'].sort
  end

  context 'cart tags' do

    before :all do
      @page = pages(:home)
    end

    before :each do
      @order = shop_orders(:several_items)
      mock_valid_tag_for_helper
    end

    describe '<r:shop:cart>' do
      context 'success' do
        it 'should render' do
          mock(Shop::Tags::Helpers).current_order(anything) { @order }

          tag = %{<r:shop:cart>success</r:shop:cart>}
          expected = %{success}

          @page.should render(tag).as(expected)

          @tag.locals.page.request.session[:shop_order].should be_nil
        end
      end

      context 'failure' do
        it 'should render' do
          tag = %{<r:shop:cart>success</r:shop:cart>}
          expected = %{success}

          @page.should render(tag).as(expected)
        end
      end
    end

    describe '<r:shop:cart:forget>' do
      it 'should remove the cart from the session' do
        pending 'dont know how to test this'
        @tag.locals.page.request.session[:shop_order] = @order

        tag = %{<r:shop:cart />}
        expected = %{}

        @page.should render(tag).as(expected)
      end
    end

    describe '<r:shop:cart:if_cart>' do
      context 'success' do
        it 'should render' do
          mock(Shop::Tags::Helpers).current_order(anything) { @order }

          tag = %{<r:shop:cart:if_cart>success</r:shop:cart:if_cart>}
          expected = %{success}
          @page.should render(tag).as(expected)
        end
      end
      context 'failure' do
        it 'should render' do
          mock(Shop::Tags::Helpers).current_order(anything) { nil }

          tag = %{<r:shop:cart:if_cart>failure</r:shop:cart:if_cart>}
          expected = %{}
          @page.should render(tag).as(expected)
        end
      end
    end

    describe '<r:shop:cart:unless_cart>' do
      context 'success' do
        it 'should render' do
          mock(Shop::Tags::Helpers).current_order(anything) { nil }

          tag = %{<r:shop:cart:unless_cart>success</r:shop:cart:unless_cart>}
          expected = %{success}
          @page.should render(tag).as(expected)
        end
      end
      context 'failure' do
        it 'should render' do
          mock(Shop::Tags::Helpers).current_order(anything) { @order }

          tag = %{<r:shop:cart:unless_cart>failure</r:shop:cart:unless_cart>}
          expected = %{}
          @page.should render(tag).as(expected)
        end
      end
    end

    context 'payment' do
      before :each do
        mock(Shop::Tags::Helpers).current_order(anything) { @order }
        @order.status = 'paid'
      end

      describe '<r:shop:cart:payment />' do
        context 'payment exists' do
          it 'should expand' do
            tag = %{<r:shop:cart:payment>success</r:shop:cart:payment>}
            expected = %{success}
            @page.should render(tag).as(expected)
          end
        end
        context 'payment doesnt exist' do
          it 'should expand' do
            stub(@order).paid? { false }
            tag = %{<r:shop:cart:payment>success</r:shop:cart:payment>}
            expected = %{success}
            @page.should render(tag).as(expected)
          end
        end
      end

      describe '<r:shop:cart:payment:if_paid />' do
        context 'payment exists' do
          it 'should expand' do
            tag = %{<r:shop:cart:payment:if_paid>success</r:shop:cart:payment:if_paid>}
            expected = %{success}
            @page.should render(tag).as(expected)
          end
        end
        context 'payment doesnt exist' do
          it 'should expand' do
            stub(@order).paid? { false }
            tag = %{<r:shop:cart:payment:if_paid>failure</r:shop:cart:payment:if_paid>}
            expected = %{}
            @page.should render(tag).as(expected)
          end
        end
      end

      describe '<r:shop:cart:payment:unless_paid />' do
        context 'payment exists' do
          it 'should expand' do
            stub(@order).paid? { false }
            tag = %{<r:shop:cart:payment:unless_paid>success</r:shop:cart:payment:unless_paid>}
            expected = %{success}
            @page.should render(tag).as(expected)
          end
        end
        context 'payment doesnt exist' do
          it 'should expand' do
            tag = %{<r:shop:cart:payment:unless_paid>failure</r:shop:cart:payment:unless_paid>}
            expected = %{}
            @page.should render(tag).as(expected)
          end
        end
      end

      describe '<r:shop:cart:payment:date />' do
        it 'should return the created_at date of the payment' do
          tag = %{<r:shop:cart:payment:date />}
          expected = @order.payment.created_at.strftime(Radiant::Config['shop.date_format'])
          @page.should render(tag).as(expected)
        end
      end

    end

    describe 'simple attributes' do
      before :each do
        mock(Shop::Tags::Helpers).current_order(anything) { @order }
      end
      it 'should render <r:id />' do
        tag = %{<r:shop:cart:id />}
        expected = @order.id.to_s

        @page.should render(tag).as(expected)
      end
      it 'should render <r:status />' do
        tag = %{<r:shop:cart:status />}
        expected = @order.status

        @page.should render(tag).as(expected)
      end
      it 'should render <r:quantity />' do
        stub(@shop_order).quantity { 1 }

        tag = %{<r:shop:cart:quantity />}
        expected = @order.quantity.to_s

        @page.should render(tag).as(expected)
      end
      it 'should render <r:weight />' do
        tag = %{<r:shop:cart:weight />}
        expected = @order.weight.to_s

        @page.should render(tag).as(expected)
      end
      it 'should render <r:notes />' do
        tag = %{<r:shop:cart:notes />}
        expected = @order.notes.to_s

        @page.should render(tag).as(expected)
      end
    end

    describe '<r:price />' do
      before :each do
        mock(Shop::Tags::Helpers).current_order(anything) { @order }
        stub(@order).price { 1234.34567890 }
      end

      it 'should render a standard price' do
        tag = %{<r:shop:cart:price />}
        expected = %{$1,234.35}

        @page.should render(tag).as(expected)
      end

      it 'should render a high precision price' do
        tag = %{<r:shop:cart:price precision="8"/>}
        expected = %{$1,234.34567890}

        @page.should render(tag).as(expected)
      end

      it 'should render a custom format' do
        tag = %{<r:shop:cart:price unit="%" separator="-" delimiter="+" />}
        expected = %{%1+234-35}

        @page.should render(tag).as(expected)
      end
    end

  end

end