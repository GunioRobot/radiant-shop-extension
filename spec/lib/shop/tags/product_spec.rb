require File.dirname(__FILE__) + "/../../../spec_helper"

describe Shop::Tags::Product do

  dataset :pages, :shop_config, :shop_products, :shop_attachments

  it 'should describe these tags' do
    Shop::Tags::Product.tags.sort.should == [
      'shop:products',
      'shop:products:if_products',
      'shop:products:unless_products',
      'shop:products:each',
      'shop:product',
      'shop:product:if_current',
      'shop:product:unless_current',
      'shop:product:page',
      'shop:product:id',
      'shop:product:name',
      'shop:product:price',
      'shop:product:sku',
      'shop:product:slug',
      'shop:product:description',
      'shop:product:link',
      'shop:product:images'].sort
  end

  before :all do
    @page     = pages(:home)
  end

  before(:each) do
    @product  = shop_products(:soft_bread)
    @products = [ shop_products(:soft_bread), shop_products(:crusty_bread) ]

    @image    = images(:soft_bread_front)
    @images   = [ images(:soft_bread_front), images(:soft_bread_back), images(:soft_bread_top) ]
  end

  describe '<r:shop:products>' do
    context 'no products exist' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { [] }
      end

      it 'should render' do
        tag = %{<r:shop:products>success</r:shop:products>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end

    context 'products exist' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { @products }
      end

      it 'should render' do
        tag = %{<r:shop:products>success</r:shop:products>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:products:if_products>' do
    context 'success' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { @products }
      end

      it 'should render' do
        tag = %{<r:shop:products:if_products>success</r:shop:products:if_products>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
    end

    context 'failure' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { [] }
      end

      it 'should not render' do
        tag = %{<r:shop:products:if_products>failure</r:shop:products:if_products>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:unless_products>' do
    context 'success' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { [] }
      end

      it 'should render' do
        tag = %{<r:shop:products:unless_products>success</r:shop:products:unless_products>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
    end

    context 'failure' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { @products }
      end

      it 'should not render' do
        tag = %{<r:shop:products:unless_products>failure</r:shop:products:unless_products>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:products:each>' do
    context 'success' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { @products }
      end

      it 'should not render' do
        tag = %{<r:shop:products:each><r:product:id /></r:shop:products:each>}
        exp = @products.map{ |p| p.id }.join('')
        @page.should render(tag).as(exp)
      end
    end

    context 'failure' do
      before :each do
        mock(Shop::Tags::Helpers).current_products(anything) { [] }
      end

      it 'should not render' do
        tag = %{<r:shop:products:each>failure</r:shop:products:each>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:product>' do
    context 'product exists in the context' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @products }
      end

      it 'should render' do
        tag = %{<r:shop:product>success</r:shop:product>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
    end

    context 'product does not exist in the context' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { [] }
      end

      it 'should not render' do
        tag = %{<r:shop:product>failure</r:shop:product>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end

    context '<r:shop:product:page>' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      it 'should set the page context from the product' do
        tag = %{<r:shop:product:page><r:title/></r:shop:product:page>}
        exp = @product.page.title.to_s
        @page.should render(tag).as(exp)
      end
    end

    context '<r:shop:product:if_current>' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      it 'should render if the page belongs to the product' do
        tag = %{<r:shop:product:if_current>success</r:shop:product:if_current>}
        exp = %{success}
        @product.page.should render(tag).as(exp)
      end

      it 'should not render if the page does not belong to the product' do
        tag = %{<r:shop:product:if_current>failure</r:shop:product:if_current>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end

    context '<r:shop:product:unless_current>' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      it 'should render if the page does not belong to the product' do
        tag = %{<r:shop:product:unless_current>success</r:shop:product:unless_current>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end

      it 'should not render if the page belongs to the product' do
        tag = %{<r:shop:product:unless_current>failure</r:shop:product:unless_current>}
        exp = %{}
        @product.page.should render(tag).as(exp)
      end
    end

    context '#attributes' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      describe '<r:id />' do
        it 'should render the product id' do
          tag = %{<r:shop:product:id />}
          exp = @product.id.to_s
          @page.should render(tag).as(exp)
        end
      end
      describe '<r:name />' do
        it 'should render the product name' do
          tag = %{<r:shop:product:name />}
          exp = @product.name
          @page.should render(tag).as(exp)
        end
      end
      describe '<r:sku />' do
        it 'should render the product sku' do
          tag = %{<r:shop:product:sku />}
          exp = @product.sku
          @page.should render(tag).as(exp)
        end
      end
      describe '<r:slug />' do
        it 'should render the product slug' do
          tag = %{<r:shop:product:slug />}
          exp = @product.slug
          @page.should render(tag).as(exp)
        end
      end
      describe '<r:description />' do
        it 'should render a textile filtered description' do
          tag = %{<r:shop:product:description />}
          exp = TextileFilter.filter(@product.description)

          @page.should render(tag).as(exp)
        end
      end
    end

    describe '<r:link />' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      context 'standalone' do
        it 'should render an anchor element' do
          tag = %{<r:shop:product:link />}
          exp = %{<a href="#{@product.url}">#{@product.name}</a>}
          @page.should render(tag).as(exp)
        end
        it 'should assign attributes' do
          tag = %{<r:shop:product:link title="title" data-title="data-title"/>}
          exp = %{<a href="#{@product.url}" data-title="data-title" title="title">#{@product.name}</a>}
          @page.should render(tag).as(exp)
        end
      end

      context 'wrapped' do
        it 'should render an anchor element' do
          tag = %{<r:shop:product:link>title</r:shop:product:link>}
          exp = %{<a href="#{@product.url}">title</a>}
          @page.should render(tag).as(exp)
        end
      end
    end

    describe '<r:price />' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
        stub(@product).price { 1234.34567890 }
      end

      it 'should render a standard price' do
        tag = %{<r:shop:product:price />}
        exp = %{$1,234.35}
        @page.should render(tag).as(exp)
      end

      it 'should not be testing precision here'

      it 'should render a high precision price' do
        tag = %{<r:shop:product:price precision="8"/>}
        exp = %{$1,234.34567890}
        @page.should render(tag).as(exp)
      end

      it 'should render a custom format' do
        tag = %{<r:shop:product:price unit="%" separator="-" delimiter="+" />}
        exp = %{%1+234-35}
        @page.should render(tag).as(exp)
      end
    end

    describe '<r:shop:product:images>' do
      before :each do
        mock(Shop::Tags::Helpers).current_product(anything) { @product }
      end

      context 'success' do
        it 'should open if images exist' do
          tag = %{<r:shop:product:images>success</r:shop:product:images>}
          exp = %{success}
          @page.should render(tag).as(exp)
        end
        it 'should assign images for default tags' do
          tag = %{<r:shop:product:images:each:image>success</r:shop:product:images:each:image>}
          exp = @product.images.map{'success'}.join('')
          @page.should render(tag).as(exp)
        end
      end
      context 'failure' do
        before :each do
          @product.page.attachments.destroy_all
        end
        it 'should render' do
          tag = %{<r:shop:product:images>success</r:shop:product:images>}
          exp = %{success}
          @page.should render(tag).as(exp)
        end
        it 'should not assign images for default tags' do
          tag = %{<r:shop:product:images:each:image>failure</r:shop:product:images:each:image>}
          exp = %{}
          @page.should render(tag).as(exp)
        end
      end
    end

  end

end
