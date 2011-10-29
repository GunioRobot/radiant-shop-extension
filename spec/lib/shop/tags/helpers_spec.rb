require File.dirname(__FILE__) + "/../../../spec_helper"

describe Shop::Tags::Helpers do

  dataset :pages, :tags, :shop_products, :shop_orders, :shop_addresses, :shop_line_items, :shop_attachments

  before :all do
    @page = pages(:home)
  end

  before(:each) do
    mock_valid_tag_for_helper
  end

  describe '#current_categories' do
    before :each do
      @category   = shop_categories(:bread)
    end

    context 'parent sent' do
      before :each do
        @tag.attr = { 'parent' => @category.page.parent.slug }
      end
      it 'should return the matching categories' do
        result = Shop::Tags::Helpers.current_categories(@tag)
        result.should == @category.page.parent.children.map(&:shop_category)
      end
    end

    context 'categories previously set' do
      before :each do
        @tag.locals.shop_categories = [@category]
      end
      it 'should return categories' do
        result = Shop::Tags::Helpers.current_categories(@tag)
        result.should == [@category]
      end
    end

    context 'nothing additional sent' do
      it 'should return all categories in the database' do
        result = Shop::Tags::Helpers.current_categories(@tag)
        result.should == ShopCategory.all
      end
    end
  end

  it 'should test nested categories'

  describe '#current_category' do
    before :each do
      @category = shop_categories(:bread)
      @product  = shop_categories(:bread).products.first
    end

    context 'name sent' do
      before :each do
        @tag.attr = { 'name' => @category.name }
      end
      it 'should return the matching category' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'handle sent' do
      before :each do
        @tag.attr = { 'handle' => @category.slug }
      end
      it 'should return the matching category' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'category previously set' do
      before :each do
        @tag.locals.shop_category = @category
      end
      it 'should return the existing category' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'product previously set' do
      before :each do
        @tag.locals.shop_product = @product
      end
      it 'should return the category of the product attached to the page' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'the current page has a product attached to it' do
      before :each do
        @tag.locals.page.shop_product = @product
      end
      it 'should return the category of the product attached to the page' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'the current page has a category attached to it' do
      before :each do
        @tag.locals.page.shop_category = @category
      end
      it 'should return the category attached to the page' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should == @category
      end
    end

    context 'nothing available to find the category' do
      it 'should return nil' do
        result = Shop::Tags::Helpers.current_category(@tag)
        result.should be_nil
      end
    end

  end

  describe '#current_products' do
    before :each do
      @product  = shop_products(:soft_bread)
      @category = shop_categories(:bread)
    end

    context 'category sent' do
      before :each do
        @tag.attr = { 'category' => @product.category.page.slug }
      end
      it 'should return the matching products' do
        result = Shop::Tags::Helpers.current_products(@tag)
        result.should == @product.page.parent.children.map(&:shop_product)
      end
    end

    context 'products previously set' do
      before :each do
        @tag.locals.shop_products = [ @product ]
      end
      it 'should return the existing categories' do
        result = Shop::Tags::Helpers.current_products(@tag)
        result.should == [@product]
      end
    end

    context 'category previously set' do
      before :each do
        @tag.locals.shop_category = @category
      end
      it 'should return the categorys products' do
        result = Shop::Tags::Helpers.current_products(@tag)
        result.should == @category.products
      end
    end

    context 'the current page has a category attached to it' do
      before :each do
        @tag.locals.page.shop_category = @category
      end
      it 'should return the products of the category attached to the page' do
        result = Shop::Tags::Helpers.current_products(@tag)
        result.should == @category.products
      end
    end

    context 'nothing additional sent' do
      before :each do
        mock(ShopProduct).all { [@product] }
      end
      it 'should return all products in the database' do
        result = Shop::Tags::Helpers.current_products(@tag)
        result.should == [@product]
      end
    end
  end

  describe '#current_product' do
    before :each do
      @product    = shop_products(:soft_bread)
      @line_item  = shop_line_items(:one)
    end

    context 'name sent' do
      before :each do
        @tag.attr = { 'name' => @product.name }
      end
      it 'should return the matching product' do
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == @product
      end
    end

    context 'sku sent' do
      before :each do
        @tag.attr = { 'sku' => @product.slug }
      end
      it 'should return the matching product' do
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == @product
      end
    end

    context 'sku not unique' do
      it 'should use the full slug not the single product url'
    end

    context 'product previously set' do
      before :each do
        @tag.locals.shop_product = @product
      end
      it 'should return the product in that context' do
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == @product
      end
    end

    context 'position sent' do
      before :each do
        @tag.locals.shop_category = shop_categories(:bread)
      end
      it 'should return the matching product at that position' do
        @tag.attr = { 'position' => 1 }
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == shop_categories(:bread).products[0]
      end
      it 'should return the matching product at that position or the first' do
        @tag.attr = { 'position' => 0 }
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == shop_categories(:bread).products[0]
      end
    end

    context 'line item previously set' do
      context 'for product' do
        before :each do
          @tag.locals.shop_line_item = @line_item
        end
        it 'should return the product of the line item' do
          result = Shop::Tags::Helpers.current_product(@tag)
          result.should == @line_item.item
        end
      end
      context 'not for product' do
        before :each do
          @line_item.item_type = 'ShopOther'
          @tag.locals.shop_line_item = @line_item
        end
        it 'should not return the product' do
          result = Shop::Tags::Helpers.current_product(@tag)
          result.should be_nil
        end
      end
    end

    context 'the current page has a product attached to it' do
      before :each do
        @tag.locals.page.shop_product = @product
      end
      it 'should return the product attached to the page' do
        result = Shop::Tags::Helpers.current_product(@tag)
        result.should == @product
      end
    end

  end

  describe '#current_image' do
    before :each do
      @attachment = shop_products(:crusty_bread).attachments.first
    end

    context 'image previously set' do
      before :each do
        @tag.locals.image = @attachment
      end
      it 'should return the image' do
        result = Shop::Tags::Helpers.current_image(@tag)
        result.should == @attachment.image
      end
    end

    context 'position set' do
      before :each do
        @tag.locals.images = shop_products(:crusty_bread).attachments
        @tag.attr = { 'position' => 1 }
      end
      it 'should return the image at that position' do
        result = Shop::Tags::Helpers.current_image(@tag)
        result.should == shop_products(:crusty_bread).attachments[0]
      end
    end
  end

  describe '#current_order' do
    before :each do
      @order = shop_orders(:one_item)
    end

    context 'order previously set' do
      before :each do
        @tag.locals.shop_order = @order
      end
      it 'should return the order' do
        result = Shop::Tags::Helpers.current_order(@tag)
        result.should == @order
      end
    end

    context 'key and value sent' do
      before :each do
        @tag.attr = { 'key' => 'id', 'value' => @order.id }
      end
      it 'should return the matching order' do
        result = Shop::Tags::Helpers.current_order(@tag)
        result.should == @order
      end
    end

    context 'session contains the order id' do
      before :each do
        @tag.locals.page.request.session[:shop_order] = @order.id
      end
      it 'should return the order with that id' do
        result = Shop::Tags::Helpers.current_order(@tag)
        result.should == @order
      end
    end

    context 'nothing available to find the product' do
      it 'should return nil' do
        result = Shop::Tags::Helpers.current_order(@tag)
        result.should be_nil
      end
    end

  end

  describe '#current_line_items' do
    before :each do
      @order = shop_orders(:several_items)
      @tag.locals.shop_order = @order
    end

    context 'line items previously set' do
      before :each do
        @tag.locals.shop_line_items = [@order.line_items.first]
      end
      it 'should return the order' do
        result = Shop::Tags::Helpers.current_line_items(@tag)
        result.should == [@order.line_items.first]
      end
    end

    context 'nothing available to find the items' do
      it 'should return the current orders items' do
        result = Shop::Tags::Helpers.current_line_items(@tag)
        result.should == @order.line_items
      end
    end

  end

  describe '#current_line_item' do
    before :each do
      @item = shop_line_items(:one)
    end

    context 'existing line item' do
      before :each do
        @tag.locals.shop_line_item = @item
      end
      it 'should return that existing line item' do
        result = Shop::Tags::Helpers.current_line_item(@tag)
        result.should == @item
      end
    end

    context 'existing product and category' do
      before :each do
        @tag.locals.shop_order = shop_orders(:one_item)
        @tag.locals.shop_product = shop_products(:crusty_bread)
      end
      it 'should return the item linking the two' do
        result = Shop::Tags::Helpers.current_line_item(@tag)
        result.should == @item
      end
    end
  end

  describe '#current_address' do
    before :each do
      @address  = shop_billings(:order_billing)
      @tag.attr = { 'type' => 'billing' }
    end

    context 'billing address already exists' do
      before :each do
        @tag.locals.billing = @address
      end
      it 'should return the existing billing' do
        result = Shop::Tags::Helpers.current_address(@tag,'billing')
        result.should == @address
      end
      it 'should return the existing billing if no type is sent' do
        result = Shop::Tags::Helpers.current_address(@tag)
        result.should == @address
      end
    end

    context 'shipping address already exists' do
      before :each do
        @tag.locals.shipping = @address
      end
      it 'should return the existing address' do
        result = Shop::Tags::Helpers.current_address(@tag,'shipping')
        result.should == @address
      end
    end

    context 'current_order exists and has billing' do
      before :each do
        @order = shop_orders(:one_item)
        @order.update_attribute(:billing, @address)
        @tag.locals.shop_order = @order
      end
      it 'should return the order billing address' do
        result = Shop::Tags::Helpers.current_address(@tag,'billing')
        result.should == @address
      end
    end

    context 'current order exists and doesnt have billing' do
      before :each do
        @order = shop_orders(:one_item)
      end
      it 'should return nil' do
        result = Shop::Tags::Helpers.current_address(@tag,'billing')
        result.should be_nil
      end
    end

    context 'no order exists' do
      it 'should return nil' do
        result = Shop::Tags::Helpers.current_address(@tag,'billing')
        result.should be_nil
      end
    end

    context 'no order exists but user does' do
      before :each do
        @user = User.new
        stub(@user).billing { @address }
        mock(Users::Tags::Helpers).current_user(anything) { @user }
      end
      it 'should return nil' do
        result = Shop::Tags::Helpers.current_address(@tag,'billing')
        result.should == @address
      end
    end
  end

end