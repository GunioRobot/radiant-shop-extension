require File.dirname(__FILE__) + "/../../../spec_helper"

#
# Tests for shop address tags
#
describe Shop::Tags::Tax do

  dataset :pages, :shop_line_items

  it 'should describe these tags' do
    Shop::Tags::Tax.tags.sort.should == [
      'shop:cart:tax',
      'shop:cart:tax:if_tax',
      'shop:cart:tax:unless_tax',
      'shop:cart:tax:name',
      'shop:cart:tax:percentage',
      'shop:cart:tax:strategy',
      'shop:cart:tax:cost',
      'shop:cart:tax:if_inclusive',
      'shop:cart:tax:if_exclusive'
    ].sort
  end

  context 'inside cart' do
    before :all do
      Radiant::Config['shop.tax_strategy']   = 'inclusive'
      Radiant::Config['shop.tax_name']       = 'gst'
      Radiant::Config['shop.tax_percentage'] = '10'
      @page = pages(:home)
    end

    before :each do
      @order = shop_orders(:several_items)
      mock(Shop::Tags::Helpers).current_order(anything) { @order }
    end

    describe '<r:shop:cart:tax/>' do
      it 'should expand' do
        tag = %{<r:shop:cart:tax>success</r:shop:cart:tax>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:cart:tax:if_tax />' do
      context 'tax configured correctly' do
        context 'inclusive' do
          before :each do
            Radiant::Config['shop.tax_strategy'] = 'inclusive'
          end
          it 'should expand' do
            tag = %{<r:shop:cart:tax:if_tax>success</r:shop:cart:tax:if_tax>}
            exp = %{success}

            @page.should render(tag).as(exp)
          end
        end
        context 'exclusive' do
          before :each do
            Radiant::Config['shop.tax_strategy'] = 'exclusive'
          end
          it 'should expand' do
            tag = %{<r:shop:cart:tax:if_tax>success</r:shop:cart:tax:if_tax>}
            exp = %{success}

            @page.should render(tag).as(exp)
          end
        end
      end
      context 'tax not configured correctly' do
        before :each do
          Radiant::Config['shop.tax_strategy'] = 'failure'
        end
        it 'should not expand' do
          tag = %{<r:shop:cart:tax:if_tax>failure</r:shop:cart:tax:if_tax>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe '<r:shop:cart:tax:unless_tax />' do
      context 'tax configured correctly' do
        context 'inclusive' do
          before :each do
            Radiant::Config['shop.tax_strategy'] = 'inclusive'
          end
          it 'should not expand' do
            tag = %{<r:shop:cart:tax:unless_tax>failure</r:shop:cart:tax:unless_tax>}
            exp = %{}

            @page.should render(tag).as(exp)
          end
        end
        context 'exclusive' do
          before :each do
            Radiant::Config['shop.tax_strategy'] = 'exclusive'
          end
          it 'should not expand' do
            tag = %{<r:shop:cart:tax:unless_tax>failure</r:shop:cart:tax:unless_tax>}
            exp = %{}

            @page.should render(tag).as(exp)
          end
        end
      end
      context 'tax not configured correctly' do
        before :each do
          Radiant::Config['shop.tax_strategy'] = 'failure'
        end
        it 'should expand' do
          tag = %{<r:shop:cart:tax:unless_tax>success</r:shop:cart:tax:unless_tax>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe '<r:shop:cart:tax:strategy/>' do
      it 'should return the tax strategy' do
        tag = %{<r:shop:cart:tax:strategy/>}
        exp = Radiant::Config['shop.tax_strategy']

        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:cart:tax:name/>' do
      it 'should return the tax name' do
        tag = %{<r:shop:cart:tax:name/>}
        exp = Radiant::Config['shop.tax_name']

        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:cart:tax:percentage/>' do
      it 'should return the tax percentage' do
        tag = %{<r:shop:cart:tax:percentage/>}
        exp = Radiant::Config['shop.tax_percentage']

        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:cart:tax:cost/>' do
      it 'should return the cost of tax on the cart' do
        tag = %{<r:shop:cart:tax:cost/>}
        exp = ::Shop::Tags::Helpers.currency(@order.tax)

        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:cart:tax:if_inclusive/>' do
      context 'is inclusive' do
        it 'should expand' do
          Radiant::Config['shop.tax_strategy'] = 'inclusive'
          tag = %{<r:shop:cart:tax:if_inclusive>success</r:shop:cart:tax:if_inclusive>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'not inclusive' do
        it 'should not expand' do
          Radiant::Config['shop.tax_strategy'] = 'exclusive'
          tag = %{<r:shop:cart:tax:if_inclusive>failure</r:shop:cart:tax:if_inclusive>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    describe '<r:shop:cart:tax:if_exclusive/>' do
      context 'is exclusive' do
        it 'should expand' do
          Radiant::Config['shop.tax_strategy'] = 'exclusive'
          tag = %{<r:shop:cart:tax:if_exclusive>success</r:shop:cart:tax:if_exclusive>}
          exp = %{success}

          @page.should render(tag).as(exp)
        end
      end
      context 'not exclusive' do
        it 'should not expand' do
          Radiant::Config['shop.tax_strategy'] = 'inclusive'
          tag = %{<r:shop:cart:tax:if_exclusive>failure</r:shop:cart:tax:if_exclusive>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end
  end

end