require File.dirname(__FILE__) + "/../../../spec_helper"
require 'spec/helpers/nested_tag_helper'

#
# Test for Shop Line Item Tags
#
describe Shop::Tags::Item do

  dataset :pages, :shop_config, :shop_orders, :shop_line_items

  it 'should describe these tags' do
    Shop::Tags::Item.tags.sort.should == [
      'shop:cart:items',
      'shop:cart:items:if_items',
      'shop:cart:items:unless_items',
      'shop:cart:items:each',
      'shop:cart:item',
      'shop:cart:item:id',
      'shop:cart:item:quantity',
      'shop:cart:item:name',
      'shop:cart:item:price',
      'shop:cart:item:sku',
      'shop:cart:item:link'].sort
  end

  context 'within a cart' do

    before :all do
      @page = pages(:home)
    end

    context 'order does not exist' do
      describe '<r:shop:cart:items>' do
        it 'should not render' do
          tag = %{<r:shop:cart:items>failure</r:shop:cart:items>}
          exp = %{}

          @page.should render(tag).as(exp)
        end
      end
    end

    context 'order exists' do
      before :each do
        @order = shop_orders(:several_items)
        mock(Shop::Tags::Helpers).current_order(anything) { @order }
      end
      describe '<r:shop:cart:items>' do
        context 'items exist in cart' do
          context 'no parameters sent to tag' do
            it 'should render' do
              tag = %{<r:shop:cart:items>success</r:shop:cart:items>}
              exp = %{success}

              @page.should render(tag).as(exp)
            end
          end
          context 'parameters sent to tag' do
            it 'should render' do
              tag = %{<r:shop:cart:items key='id' value='#{@order.line_items.first.id}'>success</r:shop:cart:items>}
              exp = %{success}

              @page.should render(tag).as(exp)
            end
          end
        end

        context 'items dont exist in cart' do
          it 'should render' do
            tag = %{<r:shop:cart:items>success</r:shop:cart:items>}
            exp = %{success}

            @page.should render(tag).as(exp)
          end
        end
      end

      describe '<r:shop:cart:items:if_items>' do
        context 'success' do
          it 'should render' do
            tag = %{<r:shop:cart:items:if_items>success</r:shop:cart:items:if_items>}
            exp = %{success}
            @page.should render(tag).as(exp)
          end
        end
        context 'failure' do
          it 'should render' do
            stub(@order).line_items { [] }

            tag = %{<r:shop:cart:items:if_items>failure</r:shop:cart:items:if_items>}
            exp = %{}
            @page.should render(tag).as(exp)
          end
        end
      end

      describe '<r:shop:cart:items:unless_items>' do
        context 'success' do
          it 'should render' do
            stub(@order).line_items { [] }

            tag = %{<r:shop:cart:items:unless_items>success</r:shop:cart:items:unless_items>}
            exp = %{success}
            @page.should render(tag).as(exp)
          end
        end
        context 'failure' do
          it 'should render' do
            tag = %{<r:shop:cart:items:unless_items>failure</r:shop:cart:items:unless_items>}
            exp = %{}
            @page.should render(tag).as(exp)
          end
        end
      end

      describe '<r:shop:cart:items:each>' do
        context 'success' do
          it 'should render' do
            tag = %{<r:shop:cart:items:each:item>.a.</r:shop:cart:items:each:item>}
            exp = @order.line_items.map{ '.a.' }.join('')

            @page.should render(tag).as(exp)
          end
          it 'should assign the local item' do
            tag = %{<r:shop:cart:items:each:item><r:id /></r:shop:cart:items:each:item>}
            exp = @order.line_items.map{ |i| i.id }.join('')

            @page.should render(tag).as(exp)
          end
          it 'should assign the local item' do
            tag = %{<r:shop:cart:items:each:item><r:product:name /></r:shop:cart:items:each:item>}
            exp = @order.line_items.map{ |i| i.item.name }.join('')

            @page.should render(tag).as(exp)
          end
        end
        context 'failure' do
          it 'should not render' do
            stub(@order).line_items { [] }

            tag = %{<r:shop:cart:items:each></r:shop:cart:items:each>}
            exp = %{}

            @page.should render(tag).as(exp)
          end
        end
      end
    end

    context 'a single item' do
      before :each do
        @order = shop_orders(:several_items)
        mock(Shop::Tags::Helpers).current_order(anything) { @order }
        @line_item = @order.line_items.first
      end
      describe '<r:shop:cart:item>' do
        context 'success' do
          it 'should render' do
            mock(Shop::Tags::Helpers).current_line_item(anything) { @line_item }

            tag = %{<r:shop:cart:item>success</r:shop:cart:item>}
            exp = %{success}

            @page.should render(tag).as(exp)
          end
        end

        context 'failure' do
          it 'should not render' do
            mock(Shop::Tags::Helpers).current_line_item(anything) { nil }
            tag = %{<r:shop:cart:item>failure</r:shop:cart:item>}
            exp = %{}

            @page.should render(tag).as(exp)
          end
        end

        describe 'simple attributes' do
          before :each do
            mock(Shop::Tags::Helpers).current_line_item(anything) { @line_item }
          end
          it 'should render <r:id />' do
            tag = %{<r:shop:cart:item:id />}
            exp = @line_item.id.to_s

            @page.should render(tag).as(exp)
          end
          it 'should render <r:quantity />' do
            tag = %{<r:shop:cart:item:quantity />}
            exp = @line_item.quantity.to_s

            @page.should render(tag).as(exp)
          end
        end

        describe 'item attributes' do
          before :each do
            mock(Shop::Tags::Helpers).current_line_item(anything) { @line_item }
          end
          it 'should render <r:name />' do
            tag = %{<r:shop:cart:item:name />}
            exp = @line_item.item.name

            @page.should render(tag).as(exp)
          end
          it 'should render <r:sku />' do
            tag = %{<r:shop:cart:item:sku />}
            exp = @line_item.item.sku

            @page.should render(tag).as(exp)
          end
        end

        describe '<r:shop:cart:item:link />' do
          before :each do
            mock(Shop::Tags::Helpers).current_line_item(anything) { @line_item }
          end

          context 'standalone' do
            it 'should render an anchor element' do
              tag = %{<r:shop:cart:item:link />}
              exp = %{<a href="#{@line_item.item.url}">#{@line_item.item.name}</a>}
              pages(:home).should render(tag).as(exp)
            end
            it 'should assign attributes' do
              tag = %{<r:shop:cart:item:link title="title" data-title="data-title"/>}
              exp = %{<a href="#{@line_item.item.url}" data-title="data-title" title="title">#{@line_item.item.name}</a>}
              pages(:home).should render(tag).as(exp)
            end
          end

          context 'wrapped' do
            it 'should render an anchor element' do
              tag = %{<r:shop:cart:item:link>title</r:shop:cart:item:link>}
              exp = %{<a href="#{@line_item.item.url}">title</a>}
              pages(:home).should render(tag).as(exp)
            end
          end
        end

        describe '<r:shop:cart:item:price />' do
          before :each do
            mock(Shop::Tags::Helpers).current_line_item(anything) { @line_item }

            stub(@line_item).price { 1234.34567890 }
          end

          it 'should render a standard price' do
            tag = %{<r:shop:cart:item:price />}
            exp = %{$1,234.35}

            @page.should render(tag).as(exp)
          end

          it 'should render a high precision price' do
            tag = %{<r:shop:cart:item:price precision="8"/>}
            exp = %{$1,234.34567890}

            @page.should render(tag).as(exp)
          end

          it 'should render a custom format' do
            tag = %{<r:shop:cart:item:price unit="%" separator="-" delimiter="+" />}
            exp = %{%1+234-35}

            @page.should render(tag).as(exp)
          end
        end

      end
    end
  end
end
