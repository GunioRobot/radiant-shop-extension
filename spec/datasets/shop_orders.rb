class ShopOrdersDataset < Dataset::Base

  uses :shop_products, :users

  def load
    create_record :shop_order, :empty

    create_record :shop_order, :one_item,
      :customer => users(:admin)

    create_record :shop_order, :several_items,
      :customer => users(:admin)
  end
end
