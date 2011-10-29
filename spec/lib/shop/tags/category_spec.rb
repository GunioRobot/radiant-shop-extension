require File.dirname(__FILE__) + "/../../../spec_helper"

describe Shop::Tags::Category do

  dataset :pages, :shop_categories, :shop_products, :shop_attachments

  it 'should describe these tags' do
    Shop::Tags::Category.tags.sort.should == [
      'shop:categories',
      'shop:categories:each',
      'shop:categories:if_categories',
      'shop:categories:unless_categories',
      'shop:category',
      'shop:category:description',
      'shop:category:handle',
      'shop:category:id',
      'shop:category:if_current',
      'shop:category:unless_current',
      'shop:category:link',
      'shop:category:url',
      'shop:category:name',
      'shop:category:slug',
      'shop:category:images'].sort
  end

  before :each do
    @page = pages(:home)
  end

  before(:each) do
    @category = shop_categories(:bread)
  end

  describe '<r:shop:categories>' do
    context 'categories exist' do
      it 'should render' do
        mock(Shop::Tags::Helpers).current_categories(anything) { [@category] }
        tag = %{<r:shop:categories>success</r:shop:categories>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end
    context 'categories dont exist' do
      it 'should render' do
        mock(Shop::Tags::Helpers).current_categories(anything) { [] }
        tag = %{<r:shop:categories>success</r:shop:categories>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:categories:if_categories>' do
    context 'success' do
      it 'should render' do
        tag = %{<r:shop:categories:if_categories>success</r:shop:categories:if_categories>}
        exp = %{success}

        @page.should render(tag).as(exp)
      end
    end
    context 'failure' do
      it 'should not render' do
        mock(Shop::Tags::Helpers).current_categories(anything) { [] }

        tag = %{<r:shop:categories:if_categories>failure</r:shop:categories:if_categories>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:categories:unless_categories>' do
    context 'success' do
      it 'should render' do
        mock(Shop::Tags::Helpers).current_categories(anything) { [] }

        tag = %{<r:shop:categories:unless_categories>success</r:shop:categories:unless_categories>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
    end
    context 'failure' do
      it 'should not render' do
        tag = %{<r:shop:categories:unless_categories>failure</r:shop:categories:unless_categories>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:category:if_current>' do
    before :each do
      mock(Shop::Tags::Helpers).current_category(anything) { @category }
    end
    context 'this categories page' do
      it 'should expand' do
        tag = %{<r:shop:category:if_current>success</r:shop:category:if_current>}
        exp =  %{success}

        @category.page.should render(tag).as(exp)
      end
    end
    context 'categories product page' do
      it 'should expand' do
        tag = %{<r:shop:category:if_current>success</r:shop:category:if_current>}
        exp =  %{success}

        @category.products.first.page.should render(tag).as(exp)
      end
    end
    context 'failure' do
      it 'should not expand' do
        tag = %{<r:shop:category:if_current>failure</r:shop:category:if_current>}
        exp =  %{}

        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:category:unless_current>' do
    before :each do
      mock(Shop::Tags::Helpers).current_category(anything) { @category }
    end
    context 'this categories page' do
      it 'should not expand' do
        tag = %{<r:shop:category:unless_current>failure</r:shop:category:unless_current>}
        exp =  %{}

        @category.page.should render(tag).as(exp)
      end
    end
    context 'categories product page' do
      it 'should not expand' do
        tag = %{<r:shop:category:unless_current>failure</r:shop:category:unless_current>}
        exp =  %{}

        @category.products.first.page.should render(tag).as(exp)
      end
    end
    context 'failure' do
      it 'should expand' do
        tag = %{<r:shop:category:unless_current>success</r:shop:category:unless_current>}
        exp =  %{success}

        @page.should render(tag).as(exp)
      end
    end
  end

  describe 'simple attributes' do
    before :each do
      mock(Shop::Tags::Helpers).current_category(anything) { @category }
    end
    it 'should render <r:id />' do
      tag = %{<r:shop:category:id />}
      exp = @category.id.to_s

      @page.should render(tag).as(exp)
    end
    it 'should render <r:name />' do
      tag = %{<r:shop:category:name />}
      exp = @category.name

      @page.should render(tag).as(exp)
    end
    it 'should render <r:handle />' do
      tag = %{<r:shop:category:handle />}
      exp = @category.handle

      @page.should render(tag).as(exp)
    end
    it 'should render <r:slug />' do
      tag = %{<r:shop:category:slug />}
      exp = @category.slug

      @page.should render(tag).as(exp)
    end
    it 'should render <r:url />' do
      tag = %{<r:shop:category:url />}
      exp = @category.url

      @page.should render(tag).as(exp)
    end
    describe '<r:description />' do
      it 'should render a textile filtered result' do
        tag = %{<r:shop:category:description />}
        exp = TextileFilter.filter(@category.description)

        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:link />' do
    before :each do
      mock(Shop::Tags::Helpers).current_category(anything) { @category }
    end

    context 'standalone' do
      it 'should render an anchor element' do
        tag = %{<r:shop:category:link />}
        exp = %{<a href="#{@category.url}">#{@category.name}</a>}

        @page.should render(tag).as(exp)
      end
      it 'should assign attributes' do
        tag = %{<r:shop:category:link title="title" data-title="data-title"/>}
        exp = %{<a href="#{@category.url}" data-title="data-title" title="title">#{@category.name}</a>}

        @page.should render(tag).as(exp)
      end
    end

    context 'wrapped' do
      it 'should render an anchor element' do
        tag = %{<r:shop:category:link>title</r:shop:category:link>}
        exp = %{<a href="#{@category.url}">title</a>}

        @page.should render(tag).as(exp)
      end
    end
  end

  describe '<r:shop:category:images>' do
    before :each do
      mock(Shop::Tags::Helpers).current_category(anything) { @category }
    end

    context 'success' do
      it 'should open if images exist' do
        tag = %{<r:shop:category:images>success</r:shop:category:images>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
      it 'should assign images for default tags' do
        tag = %{<r:shop:category:images:each:image>success</r:shop:category:images:each:image>}
        exp = @category.images.map{'success'}.join('')
        @page.should render(tag).as(exp)
      end
    end
    context 'failure' do
      before :each do
        @category.page.attachments.destroy_all { [] }
      end
      it 'should render' do
        tag = %{<r:shop:category:images>success</r:shop:category:images>}
        exp = %{success}
        @page.should render(tag).as(exp)
      end
      it 'should not assign images for default tags' do
        tag = %{<r:shop:category:images:each:image>failure</r:shop:category:images:each:image>}
        exp = %{}
        @page.should render(tag).as(exp)
      end
    end
  end

end