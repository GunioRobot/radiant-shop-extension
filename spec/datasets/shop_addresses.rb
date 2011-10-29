class ShopAddressesDataset < Dataset::Base

  uses :shop_orders

  def load
    create_record :shop_billing, :order_billing,
      :name             => 'Billing Address',
      :phone            => '1800 000 000',
      :business         => 'The Business',
      :email            => 'billing@billing.com',
      :unit             => 'a',
      :street_1         => '1 Bill Street',
      :street_2         => 'Street Bill 1',
      :city             => 'Billvilles',
      :state            => 'BI',
      :country          => 'Billington',
      :of_type          => 'billing',
      :postcode         => '1234',
      :addressable_id   => shop_orders(:several_items).id,
      :addressable_type => 'ShopOrder'

    create_record :shop_shipping, :order_shipping,
      :name             => 'Shipping Address',
      :phone            => '1800 000 000',
      :email            => 'shipping@shipping.com',
      :business         => 'The Business',
      :unit             => 'b',
      :street_1         => '2 Ship Street',
      :street_2         => 'Street Ship 2',
      :city             => 'Shipvilles',
      :state            => 'SH',
      :country          => 'Shippington',
      :of_type          => 'shipping',
      :postcode         => '1234',
      :addressable_id   => shop_orders(:several_items).id,
      :addressable_type => 'ShopOrder'
  end
end
