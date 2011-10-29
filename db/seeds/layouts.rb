#---------------------------------------------------#
# Product Layout
#---------------------------------------------------#
product = Layout.new
product.name = Radiant::Config['shop.layout_product']
product.content = <<-CONTENT
<!DOCTYPE html>
<html>
  <r:shop:product>
    <head>
      <title>Product - <r:name /></title>
    </head>
    <body>

      <r:snippet name='CartOverview' />

      <div id="product_<r:slug />" class="product" data-id="<r:id />">
        <h2><r:title /></h2>
        <h3><r:price /></h3>
        <dl id="product_details">
          <dt class="description">Description</dt>
          <dd class="description"><r:description /></dd>
          <dt class="add_product">Add To Cart</dt>
          <dd class="add_product"><r:form name="CartAddProduct" /></dd>
        </dl>
      </div>
    </body>
  </r:shop:product>
</html>
CONTENT
product.save

#---------------------------------------------------#
# Category Layout
#---------------------------------------------------#
category = Layout.new
category.name = Radiant::Config['shop.layout_category']
category.content = <<-CONTENT
<!DOCTYPE html>
<html>
  <r:shop:category>
    <head>
      <title>Product - <r:name /></title>
    </head>
    <body>

      <r:snippet name='CartOverview' />

      <div id="category_<r:slug />" class="category" data-id="<r:id />">
        <h2><r:title /></h2>
        <dl id="description_details">
          <dt class="description">Description</dt>
          <dd class="description"><r:description /></dd>
        </div>
        <r:products>
          <r:if_products>
            <ul class="category_products">
              <r:each:product>
                <li class="product" id="product_<r:sku />" data-id="<r:id />"
                  <h3><r:link /></h3>
                  <h4><r:price /></h4>
                </li>
              </r:each:product>
            </ul>
          </r:if_products>
          <r:unless_products>
            <p class="error" id="shop_no_products_error">We don't have any products available here yet.</p>
          </r:unless_products>
        </r:products>
      </div>
    </body>
  </r:shop:category>
</html>
CONTENT
category.save