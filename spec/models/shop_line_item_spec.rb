require File.dirname(__FILE__) + "/../spec_helper"

describe ShopLineItem do

  dataset :shop_line_items, :shop_products

  context 'methods' do

    describe '#weight' do
      it 'should multiple weight by quanttiy' do
        shop_line_items(:one).weight.should === (shop_line_items(:one).item.weight * shop_line_items(:one).quantity).to_f
        shop_line_items(:two).weight.should === (shop_line_items(:two).item.weight * shop_line_items(:two).quantity).to_f
      end
    end

    describe '#price' do
      it 'should multiple price by quantity' do
        shop_line_items(:one).price.should === (shop_line_items(:one).item_price * shop_line_items(:one).quantity).to_f
        shop_line_items(:two).price.should === (shop_line_items(:two).item_price * shop_line_items(:two).quantity).to_f
      end
      it 'should not inherit the changes of a items base price' do
        shop_line_items(:one).price.to_f.should === shop_line_items(:one).item.price.to_f
        shop_line_items(:one).item.update_attribute(:price, 100.00)
        shop_line_items(:one).price.to_f.should_not === shop_line_items(:one).item.price.to_f
      end
    end

    describe '#to_json' do
      it 'should overload standard to_json' do
        pending 'not sure how to write this'
      end
    end

  end

  context 'filters' do

    describe '#adjust_quantity' do
      it 'should adjust quantity to 1 if less than' do
        s = ShopLineItem.new({ :item => shop_products(:crusty_bread), :quantity => 0 })
        s.valid?
        s.quantity.should === 1

        s = ShopLineItem.new({ :item => shop_products(:crusty_bread), :quantity => 1 })
        s.valid?
        s.quantity.should === 1

        s = ShopLineItem.new({ :item => shop_products(:crusty_bread), :quantity => -100 })
        s.valid?
        s.quantity.should === 1

        s = ShopLineItem.new({ :item => shop_products(:crusty_bread), :quantity => 100 })
        s.valid?
        s.quantity.should === 100
      end
    end

    describe '#set_price' do
      it 'should assign the items price to item_price before validations' do
        s = ShopLineItem.new({ :item => shop_products(:crusty_bread), :quantity => 1 })
        s.item_price.should be_nil
        s.valid?
        s.item_price.should === shop_products(:crusty_bread).price
      end
    end

  end

  describe '#attrs' do
    it 'should return attribute set' do
      ShopLineItem.attrs.should === [ :id, :quantity ]
    end
  end

  describe '#methds' do
    it 'should return method set' do
      ShopLineItem.methds.should === [ :price, :weight ]
    end
  end

  describe '#params' do
    it 'should return parameter set' do
      ShopLineItem.params.should === { :only => ShopLineItem.attrs, :methods => ShopLineItem.methds }
    end
  end

end