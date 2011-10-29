require File.dirname(__FILE__) + "/../../../spec_helper"

#
# Tests for shop address tags
#
describe Shop::Tags::Address do

  dataset :pages, :shop_addresses, :shop_orders

  it 'should describe these tags' do
    Shop::Tags::Address.tags.sort.should == [
      'shop:cart:billing',
      'shop:cart:billing:if_billing',
      'shop:cart:billing:unless_billing',
      'shop:cart:billing:id',
      'shop:cart:billing:name',
      'shop:cart:billing:phone',
      'shop:cart:billing:email',
      'shop:cart:billing:business',
      'shop:cart:billing:unit',
      'shop:cart:billing:street_1',
      'shop:cart:billing:street_2',
      'shop:cart:billing:city',
      'shop:cart:billing:state',
      'shop:cart:billing:country',
      'shop:cart:billing:postcode',
      'shop:cart:shipping',
      'shop:cart:shipping:if_shipping',
      'shop:cart:shipping:unless_shipping',
      'shop:cart:shipping:id',
      'shop:cart:shipping:name',
      'shop:cart:shipping:phone',
      'shop:cart:shipping:business',
      'shop:cart:shipping:email',
      'shop:cart:shipping:unit',
      'shop:cart:shipping:street_1',
      'shop:cart:shipping:street_2',
      'shop:cart:shipping:city',
      'shop:cart:shipping:state',
      'shop:cart:shipping:country',
      'shop:cart:shipping:postcode',
    ].sort
  end

  context 'inside cart' do
    before :all do
      @page = pages(:home)
    end

    before :each do
      @order = shop_orders(:several_items)
      @billing = shop_billings(:order_billing)
      mock(Shop::Tags::Helpers).current_order(anything) { @order }
    end

    describe 'shop:cart:billing:if_billing' do
      context 'success' do
        it 'should expand' do
          tag = %{<r:shop:cart:billing:if_billing>success</r:shop:cart:billing:if_billing>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'failure' do
        before :each do
          mock(@order).billing { nil }
        end
        it 'should not expand' do
          tag = %{<r:shop:cart:billing:if_billing>failure</r:shop:cart:billing:if_billing>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe 'shop:cart:shipping:if_shipping' do
      context 'success' do
        it 'should expand' do
          tag = %{<r:shop:cart:shipping:if_shipping>success</r:shop:cart:shipping:if_shipping>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'failure' do
        before :each do
          mock(@order).shipping { nil }
        end
        it 'should not expand' do
          tag = %{<r:shop:cart:shipping:if_shipping>failure</r:shop:cart:shipping:if_shipping>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe 'shop:cart:billing:unless_billing' do
      context 'success' do
        before :each do
          mock(@order).shipping { nil }
        end
        it 'should expand' do
          tag = %{<r:shop:cart:shipping:unless_shipping>success</r:shop:cart:shipping:unless_shipping>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'failure' do
        it 'should not expand' do
          tag = %{<r:shop:cart:shipping:unless_shipping>failure</r:shop:cart:shipping:unless_shipping>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe 'shop:cart:shipping:unless_shipping' do
      context 'success' do
        before :each do
          mock(@order).shipping { nil }
        end
        it 'should expand' do
          tag = %{<r:shop:cart:shipping:unless_shipping>success</r:shop:cart:shipping:unless_shipping>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'failure' do
        it 'should not expand' do
          tag = %{<r:shop:cart:shipping:unless_shipping>failure</r:shop:cart:shipping:unless_shipping>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe 'shop:billing' do
      context 'billing doesnt exist' do
        before :each do
          mock(@order).billing { nil }
        end
        it 'should expand' do
          tag = %{<r:shop:cart:billing>success</r:shop:cart:billing>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'billing exists' do
        it 'should expand' do
          tag = %{<r:shop:cart:billing>success</r:shop:cart:billing>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe 'attributes' do
      context 'shop:cart:billing:id' do
        it 'should return the id' do
          tag = %{<r:shop:cart:billing><r:id /></r:shop:cart:billing>}
          exp = @billing.id.to_s

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:name' do
        it 'should return the name' do
          tag = %{<r:shop:cart:billing><r:name /></r:shop:cart:billing>}
          exp = @billing.name

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:phone' do
        it 'should return the phone' do
          tag = %{<r:shop:cart:billing><r:phone /></r:shop:cart:billing>}
          exp = @billing.phone

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:business' do
        it 'should return the email' do
          tag = %{<r:shop:cart:billing><r:business /></r:shop:cart:billing>}
          exp = @billing.business

          @page.should render(tag).as(exp)
        end
      end

      context 'shop:cart:billing:email' do
        it 'should return the email' do
          tag = %{<r:shop:cart:billing><r:email /></r:shop:cart:billing>}
          exp = @billing.email

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:unit' do
        it 'should return the unit' do
          tag = %{<r:shop:cart:billing><r:unit /></r:shop:cart:billing>}
          exp = @billing.unit

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:street_1' do
        it 'should return the street' do
          tag = %{<r:shop:cart:billing><r:street_1 /></r:shop:cart:billing>}
          exp = @billing.street_1

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:street_2' do
        it 'should return the street' do
          tag = %{<r:shop:cart:billing><r:street_2 /></r:shop:cart:billing>}
          exp = @billing.street_2

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:city' do
        it 'should return the city' do
          tag = %{<r:shop:cart:billing><r:city /></r:shop:cart:billing>}
          exp = @billing.city

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:state' do
        it 'should return the city' do
          tag = %{<r:shop:cart:billing><r:state /></r:shop:cart:billing>}
          exp = @billing.state

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:country' do
        it 'should return the country' do
          tag = %{<r:shop:cart:billing><r:country /></r:shop:cart:billing>}
          exp = @billing.country

          @page.should render(tag).as(exp)
        end
      end
      context 'shop:cart:billing:postcode' do
        it 'should return the postcode' do
          tag = %{<r:shop:cart:billing><r:postcode /></r:shop:cart:billing>}
          exp = @billing.postcode

          @page.should render(tag).as(exp)
        end
      end
    end
  end

end
