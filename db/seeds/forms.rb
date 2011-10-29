#---------------------------------------------------#
# Add Cart Item
#---------------------------------------------------#
add = Form.new
add.title = 'CartAddProduct'
add.body  = <<-BODY
<r:shop:product>
  <input type="hidden" name="line_item[item_id]" value="<r:id />" />
  <input type="hidden" name="line_item[item_type]" value="ShopProduct" />

  <input type="hidden" name="line_item[quantity]" value="1" />
  <input type="submit" name="add_to_cart" id="add_to_cart_<r:id />" value="Buy Now" />
</r:shop:product>
BODY
add.config = <<-CONFIG
add_product:
  extension: line_item
  process:   add
CONFIG

add.save

#---------------------------------------------------#
# Update Cart Item
#---------------------------------------------------#
update = Form.new
update.title = 'CartUpdateItem'
update.body  = <<-BODY
<r:shop:cart>
<r:item>
  <input type="hidden" name="_method" value="put" />
  <input type="hidden" name="line_item[id]" value="<r:item:id />" />

  <input type="text" name="line_item[quantity]" value="<r:quantity />" />
  <input type="submit" name="add_to_cart" id="update_<r:id />" value="Update" />
</r:item>
</r:shop:cart>
BODY
update.config = <<-CONFIG
add_product:
  extension: line_item
  process:   modify
CONFIG

update.save

#---------------------------------------------------#
# Cart Address
#---------------------------------------------------#
address = Form.new
address.title = 'CartAddress'
address.redirect_to = '/cart/payment'
address.body  = <<-BODY
<r:shop:cart:items:if_items>
  <div id="billing" class="address">
    <r:address type='billing'>
      <h4>Address</h4>

      <r:if_address><input type="hidden" name="billing[id]" value="<r:id />" /></r:if_address>

      <ol class="address">
        <li id="billing_name_input" class="input required">
          <r:label for='billing[name]'>Full Name</r:label>
          <input type="text" name="billing[name]" value="<r:name/>" />
        </li>
        <li id="billing_email_input" class="input required">
          <r:label for='billing[email]'>Email</r:label>
          <input type="text" name="billing[email]" value="<r:email/>" />
        </li>
        <li id="billing_street_input" class="input required">
          <r:label for='billing[street]'>Street</r:label>
          <input type="text" name="billing[street]" value="<r:street/>" />
        </li>
        <li id="billing_city_input" class="input required">
          <r:label for='billing[city]'>Suburb and Postcode</r:label>
          <input type="text" name="billing[city]" value="<r:city/>" />
          <input type="text" name="billing[postcode]" value="<r:postcode/>" />
        </li>
        <li id="billing_state_input" class="input required">
          <r:label for='billing[state]'>State and Country</r:label>
          <input type="text" name="billing[state]" value="<r:state/>" />
          <input type="text" name="billing[country]" value="<r:country/>" />
        </li>
      </ol>
    </r:address>
  </div>
</r:shop:cart:items:if_items>

<r:submit value="On To Payment" />
BODY
address.config = <<-CONFIG
checkout_addresses:
  extension: address
  billing: true
CONFIG
address.save


#---------------------------------------------------#
# Cart Payment
#---------------------------------------------------#
payment = Form.new
payment.title = 'CartPayment'
payment.redirect_to = '/cart/thanks'
payment.body  = <<-BODY
<r:response:if_results extension='bogus_checkout'>
  <r:response:get name='results[bogus_checkout][message]' />
</r:response:if_results>

<r:shop:cart:items:if_items>
  <input type="hidden" name="options[order_number]" value="<r:id />" />
  <ol class="card">
    <li id="card_type_select" class="select required">
      <r:label for='card[type]'>Type of Card</r:label>
      <r:form:card:type />
      <r:hidden name='card[type]' value='bogus' /> <!-- delete me -->
    </li>
    <li id="card_name_input" class="input required">
      <r:label for='card[name]'>Name on Card</r:label>
      <r:text name='card[name]' />
    </li>
    <li id="card_number_input" class="input required">
      <r:label for='card[number]'>Card Number</r:label>
      <r:text name='card[number]' />
      <r:hidden name='card[number]' value='1' /> <!-- delete me -->
    </li>
    <li id="card_verification_input" class="input required">
      <r:label for='card[verification]'>Security Code</r:label>
      <r:text name='card[verification]' length='4' />
    </li>
    <li id="card_month_select" class="select required">
      <r:label for='card[month]'>Expiry</r:label>
      <r:form:card:month /><r:form:card:year />
    </li>
    <li id="card_submit" class="submit">
      <r:submit value='Place Order' />
    </li>
  </ol>

</r:shop:cart:items:if_items>
BODY
payment.config = <<-CONFIG
bogus_checkout:
  extension: checkout
  test: true
  gateway:
    name: bogus
CONFIG
payment.save