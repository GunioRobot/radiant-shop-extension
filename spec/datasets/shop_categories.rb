class ShopCategoriesDataset < Dataset::Base

  uses :pages

  def load
    categories = [:bread, :milk, :salad]

    create_record :layout, :category,
      :name => 'category'

    create_record :layout, :product,
      :name => 'product'

    categories.each_with_index do |category, i|
      create_record :page, category,
        :title      => category.to_s,
        :slug       => category.to_s,
        :breadcrumb => category.to_s,
        :parent     => Page.first,
        :class_name => 'ShopCategoryPage',
        :layout     => layouts(:category)

      create_record :shop_category, category,
        :product_layout => layouts(:product),
        :page       => pages(category).id

      create_record :page_part, category,
        :name       => 'description',
        :content    => "*#{category.to_s}*",
        :page       => pages(category)
    end

  end
end
