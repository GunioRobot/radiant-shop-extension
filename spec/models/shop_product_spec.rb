require File.dirname(__FILE__) + "/../spec_helper"

describe ShopProduct do
  dataset :shop_products, :shop_line_items, :shop_customers

  describe 'relationships' do
    before :each do
      @product = shop_products(:crusty_bread)
    end

    it 'should have a page Page' do
      @product.page.is_a?(Page).should be_true
    end

    it 'should have a created_by User' do
      @product.created_by = shop_customers(:customer)
      @product.created_by.is_a?(User).should be_true
    end

    it 'should have a updated_by User' do
      @product.updated_by = shop_customers(:customer)
      @product.updated_by.is_a?(User).should be_true
    end

    it 'should have many line_items' do
      @product.line_items.is_a?(Array).should be_true
    end

    it 'should have many orders' do
      @product.orders.is_a?(Array).should be_true
    end

    it 'should have many attachments' do
      @product.attachments.is_a?(Array).should be_true
    end

    it 'should have many images' do
      @product.images.is_a?(Array).should be_true
    end

  end

  describe 'validations' do
    before :each do
      @product = shop_products(:crusty_bread)
    end

    context 'page' do
      it 'should require a page' do
        @product.page = nil
        @product.valid?.should be_false
      end
    end

    context 'price' do
      it 'should require a numerical price' do
        @product.price = 'failure'
        @product.valid?.should be_false
      end

      it 'should require a positive price' do
        @product.price = -99.99
        @product.valid?.should be_false
      end
    end
  end

  describe 'methods' do
    before :each do
      @product = shop_products(:crusty_bread)
    end

    context '#name' do
      it 'should return page title' do
        @product.name.should === @product.page.title
      end
    end

    context '#sku' do
      it 'should return a handle formatted url' do
        @product.sku.should === ShopProduct.to_sku(@product.page.slug)
      end
    end

    context '#category' do
      it 'should return page title' do
        @product.category.should === @product.page.parent.shop_category
      end
    end

    context '#category_id' do
      it 'should return page title' do
        @product.category_id.should === @product.page.parent.shop_category.id
      end
    end

    context '#description' do
      it 'should return page title' do
        @product.description.should === "*#{@product.name}*"
      end
    end

    context 'url' do
      it 'should return a standard url path' do
        @product.url.should === @product.page.url
      end
    end

    context 'customers' do
      it 'should return a collection of customers' do
        @product.customers.first.should === @product.line_items.first.customer
      end
    end

    context 'customer_ids' do
      it 'should return a collection of customer_ids' do
        @product.customer_ids.first.should === @product.line_items.first.customer.id
      end
    end

    context 'image_ids' do
      it 'should return a collection of customer_ids' do
        @product.image_ids.first.should === @product.images.first.id
      end
    end

    context 'available_images' do
      it 'should return a collection of customer_ids' do
        @product.available_images.should === (Image.all - @product.images)
      end
    end

    context 'slug' do
      it 'should return the page slug' do
        @product.slug.should === @product.page.slug
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
      @product = shop_products(:crusty_bread)
    end

    context 'handle' do
      context 'slug' do
        it 'should generate on validation' do
          @product.page.slug = 'delicious_ _:_;_=_+_._~_bread'
          @product.valid?
          @product.page.slug.should === 'delicious_______________bread'
        end
      end

      context 'breadcrumb' do
        context 'has not been set' do
          it 'should generate from the slug on validation' do
            @product.page.slug = 'delicious_ _:_;_=_+_._~_bread'
            @product.page.breadcrumb = nil
            @product.valid?
            @product.page.breadcrumb.should === @product.page.title
          end
        end
        context 'has been set' do
          it 'should be left as is' do
            @product.page.breadcrumb = 'delicious_ _:_;_=_+_._~_bread'
            @product.valid?
            @product.page.breadcrumb.should === 'delicious_ _:_;_=_+_._~_bread'
          end
        end
      end
    end
  end

  describe '#attrs' do
    it 'should return attribute set' do
      ShopProduct.attrs.should === [ :id, :price, :page_id, :created_at, :updated_at ]
    end
  end

  describe '#methds' do
    it 'should return method set' do
      ShopProduct.methds.should === [ :category_id, :name, :description, :handle, :url, :customer_ids, :image_ids, :created_at, :updated_at ]
    end
  end

  describe '#params' do
    it 'should return parameter set' do
      ShopProduct.params.should === { :only => ShopProduct.attrs, :methods => ShopProduct.methds }
    end
  end

end