var Shop = {};

document.observe("dom:loaded", function() {
  Event.addBehavior({
    '.popup .close:click' : function(e) { Element.closePopup($(this)); }
  });
});

var Shop = Class.create({

  getRoute: function(route, format, id) {
    format = format || 'js';
    id = id || null;
    result = id ? ROUTES[route].replace(/(:\w+)/, id) : ROUTES[route];
    return (result + '.' + format);
  }

});

shop = new Shop();