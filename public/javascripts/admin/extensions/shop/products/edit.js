document.observe("dom:loaded", function() {
  shop_product_edit = new ShopProductEdit();
  shop_product_edit.initialize();

  Event.addBehavior({
    '#image_form:submit'                  : function(e) { shop_product_edit.imageSubmit() },
    '#browse_images_popup .image:click'   : function(e) { shop_product_edit.imageAttach($(this)) },
    '#product_attachments .delete:click'  : function(e) { shop_product_edit.imageRemove($(this).up('.image')) },
  });
});

var ShopProductEdit = Class.create({

  initialize: function() {
    this.imagesSort();
  },

  imagesSort: function() {
    var route = shop.getRoute('sort_admin_shop_product_images_path');

    Sortable.create('product_attachments', {
      constraint: false,
      overlap: 'horizontal',
      containment: ['product_attachments'],
      onUpdate: function(element) {
        new Ajax.Request(route, {
          method: 'put',
          parameters: {
            'product_id': $('shop_product_id').value,
            'attachments':Sortable.serialize('product_attachments')
          }
        });
      }.bind(this)
    })
  },

  imageAttach: function(element) {
    var route = shop.getRoute('admin_shop_product_images_path');

    showStatus('Adding Image...');
    element.hide();

    new Ajax.Request(route, {
      method: 'post',
      parameters: {
        'product_id' : $('shop_product_id').value,
        'attachment[image_id]' : element.getAttribute('data-image_id')
      },
      onSuccess: function(data) {
        $('product_attachments').insert({ 'bottom' : data.responseText});
        shop_product_edit.imagesSort();
        element.remove();
      }.bind(element),
      onFailure: function() {
        element.show();
      },
      onComplete: function() {
        hideStatus();
      }
    });
  },

  imageRemove: function(element) {
    var attachment_id = element.readAttribute('data-attachment_id');
    var route         = shop.getRoute('admin_shop_product_image_path', 'js', attachment_id);

    showStatus('Removing Image...');
    element.hide();

    new Ajax.Request(route, {
      method: 'delete',
      onSuccess: function(data) {
        $('images').insert({ 'bottom' : data.responseText })
        element.remove();
      }.bind(element),
      onFailure: function(data) {
        element.show();
      }.bind(element),
      onComplete: function() {
        hideStatus();
      }
    });
  },

  imageSubmit: function() {
    showStatus('Uploading Image...');
  }

});