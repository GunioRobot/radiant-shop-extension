class ShopPaymentsDataset < Dataset::Base

  uses :shop_orders

  def load
    create_record :shop_payments, :visa,
      :amount       => shop_orders(:several_items).price,
      :card_type    => 'visa',
      :card_number  => 'xxxx-xxxx-xxxx-1234',
      :order_id     => shop_orders(:several_items).id
  end
end
