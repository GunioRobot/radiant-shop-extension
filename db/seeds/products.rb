category = ShopCategory.create({
  :page_attributes => {
    :title     => 'Category',
    :slug      => 'category',
    :parent    => Page.first,
    :layout    => Layout.find_by_name(Radiant::Config['shop.layout_category']),
    :status_id => 100,
    :parts_attributes => [{
      :name    => 'description',
      :content => 'I am a category'
    }]
  }
})

product = ShopProduct.create({
  :price       => 10.00,
  :page_attributes => {
    :title     => 'Product',
    :parent    => category.page,
    :slug      => 'product',
    :layout    => Layout.find_by_name(Radiant::Config['shop.layout_product']),
    :status_id => 100,
    :parts_attributes => [{
      :name    => 'description',
      :content => 'I am a product'
    }]
  }
})

