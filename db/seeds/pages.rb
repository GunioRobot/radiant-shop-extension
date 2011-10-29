unless Page.first
  Radiant::Config['defaults.page.status'] = 'Published'

  home = Page.new
  home.title = 'Shop'
  home.slug = '/'
  home.breadcrumb = 'shop'
  home.class_name = 'ShopPage'
  home.status_id = 100
  home.parts = [
    PagePart.create({
      :name      => 'body',
      :filter_id => 'Textile',
      :content   => <<-CONTENT
"category":/category

"product":/category/product

<r:shop:cart:if_cart:items:if_items>"checkout":/cart</r:shop:cart:if_cart:items:if_items>
CONTENT
    })
  ]
  home.save
end

Radiant::Config['shop.root_page_id'] = Page.first.id

cart = Page.new
cart.title      = 'Cart'
cart.slug       = 'cart'
cart.breadcrumb = 'cart'
cart.parent     = Page.first
cart.class_name = 'ShopPage'
cart.status_id  = 100
cart.parts      = [
  PagePart.create({
    :name    => 'body',
    :content => "<r:snippet name='Cart' />"
  })
]
cart.save

address = Page.new
address.title      = 'Address'
address.slug       = 'address'
address.breadcrumb = 'address'
address.parent     = cart
address.class_name = 'ShopPage'
address.status_id  = 100
address.parts      = [
  PagePart.create({
    :name    => 'body',
    :content => "<r:form name='CartAddress' />"
  })
]
address.save

payment = Page.new
payment.title      = 'Payment'
payment.slug       = 'payment'
payment.breadcrumb = 'payment'
payment.parent     = cart
payment.class_name = 'ShopPage'
payment.status_id  = 100
payment.parts      = [
  PagePart.create({
    :name    => 'body',
    :content => "<r:form name='CartPayment' />"
  })
]
payment.save

payment = Page.new
payment.title      = 'Thanks'
payment.slug       = 'thanks'
payment.breadcrumb = 'thanks'
payment.parent     = cart
payment.class_name = 'ShopPage'
payment.status_id  = 100
payment.parts      = [
  PagePart.create({
    :name      => 'body',
    :filter_id => 'Textile',
    :content   => <<-CONTENT
<r:shop:cart:if_cart:payment:if_paid>

h2. Thank You

Your payment for <r:shop:cart:price /> has been received from your **<r:response:get name="card[type]" /> card**.

If you have any queries please contact us and quote order number **#<r:cart:id />**.

<r:forget />

"home":/

</r:shop:cart:if_cart:payment:if_paid>
CONTENT
  })
]
payment.save