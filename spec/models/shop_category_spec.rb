require File.dirname(__FILE__) + "/../spec_helper"

describe ShopCategory do
  dataset :shop_categories, :users

  describe 'relationships' do
    before :each do
      @category = shop_categories(:bread)
    end

    it 'should have a page Page' do
      @category.page.is_a?(Page).should be_true
    end

    it 'should have a created_by User' do
      @category.created_by = users(:admin)
      @category.created_by.is_a?(User).should be_true
    end

    it 'should have a updated_by User' do
      @category.updated_by = users(:admin)
      @category.updated_by.is_a?(User).should be_true
    end

    it 'should have a product_layout Layout' do
      @category.product_layout.is_a?(Layout).should be_true
    end
  end

  describe 'validations' do
    before :each do
      @category = shop_categories(:bread)
    end

    context 'page' do
      it 'should require a page' do
        @category.page = nil
        @category.valid?.should be_false
      end
    end
  end

  describe 'methods' do
    before :each do
      @category = shop_categories(:bread)
    end

    context '#name' do
      it 'should return page title' do
        @category.name.should === @category.page.title
      end
    end

    it 'should test #products'

    it 'should test #categories'

    context '#handle' do
      it 'should return a handle formatted url' do
        @category.handle.should === ShopProduct.to_sku(@category.page.slug)
      end
    end

    context 'url' do
      it 'should return a standard url path' do
        @category.url.should === @category.page.url
      end
    end

    context 'slug' do
      it 'should return the page slug' do
        @category.slug.should === @category.page.slug
      end
    end

    context 'to_json' do
      it 'should overload standard to_json' do
        pending 'not sure how to write this'
        # @category.to_json.should === ShopCategory.params
      end
    end

  end

  describe 'filters' do
    before :each do
      @category = shop_categories(:bread)
    end

    context 'handle' do
      context 'slug' do
        it 'should generate on validation' do
          @category.page.slug = 'delicious_ _:_;_=_+_._~_bread'
          @category.valid?
          @category.page.slug.should === 'delicious_______________bread'
        end
      end
      context 'breadcrumb' do
        context 'has not been set' do
          it 'should generate from the slug on validation' do
            @category.page.slug = 'delicious_ _:_;_=_+_._~_bread'
            @category.page.breadcrumb = nil
            @category.valid?
            @category.page.breadcrumb.should === @category.page.title
          end
        end
        context 'has been set' do
          it 'should generate on validation' do
            @category.page.breadcrumb = 'delicious_ _:_;_=_+_._~_bread'
            @category.valid?
            @category.page.breadcrumb.should === 'delicious_ _:_;_=_+_._~_bread'
          end
        end
      end
    end

    context 'product layout' do
      it 'should select on validation' do
        @category = shop_categories(:bread)
        @category.product_layout_id = nil
        @category.valid?
        @category.product_layout.should === Layout.find_by_name(Radiant::Config['shop.product_layout'])
      end
    end
  end

  describe '#attrs' do
    it 'should return attribute set' do
      ShopCategory.attrs.should === [ :id, :product_layout_id, :page_id, :created_at, :updated_at ]
    end
  end

  describe '#methds' do
    it 'should return method set' do
      ShopCategory.methds.should === [ :name, :description, :handle, :url, :created_at, :updated_at ]
    end
  end

  describe '#params' do
    it 'should return parameter set' do
      ShopCategory.params.should === { :only => ShopCategory.attrs, :methods => ShopCategory.methds }
    end
  end

end
