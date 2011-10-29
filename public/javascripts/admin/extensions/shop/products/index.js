document.observe("dom:loaded", function() {
  shop_product_index = new ShopProductIndex();
  shop_product_index.initialize();
})

var ShopProductIndex = Class.create({

  initialize: function() {
    this.sortCategories();
    this.sortProducts();
  },

  sortCategories: function() {
    var route = shop.getRoute('sort_admin_shop_categories_path');

    Sortable.create('categories', {
      overlap:    'vertical',
      only:       'category',
      handle:     'move',
      onUpdate: function() {
        new Ajax.Request(route, {
          method: 'put',
          parameters: {
            'categories':   Sortable.serialize('categories')
          }
        })
      }
    })
  },

  sortProducts: function() {
    var route = shop.getRoute('sort_admin_shop_products_path');

    var categories = new Array();
    $$('li.category').each(function(el) {
      categories.push($(el).id + '_products');
    })

    categories.each(function(category) {
      Sortable.create(category, {
        overlap:      'vertical',
        only:         'product',
        handle:       'move',
        dropOnEmpty:  true,
        hoverclass:   'hover',
        containment:  categories,
        onUpdate: function() {
          new Ajax.Request(route, {
            method:   'put',
            parameters: {
              'category_id':  $(category).readAttribute('data-id'),
              'products':     Sortable.serialize(category)
            }
          })
        }.bind(this)
      })
    })
  }

})