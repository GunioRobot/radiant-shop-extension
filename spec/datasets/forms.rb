class FormsDataset < Dataset::Base

  uses :pages, :shop_orders

  def load
    create_record :form, :checkout,
      :title    => 'Checkout',
      :body     => checkout_body,
      :config   => checkout_config,
      :content  => ''
  end

  def checkout_body
<<-BODY
<r:shop:cart>
  <div class="addresses">
    <ol class="billing">
      <li>
        <r:label for='billing[name]'>Name</r:label>
        <r:text name='billing[name]' />
      </li>
      <li>
        <r:label for='billing[unit]'>Address</r:label>
        <r:text name='billing[unit]' /> <r:text name='billing[street_1]' /> <r:text name='billing[suburb]' />
      </li>
      <li>
        <r:label for='billing[state]'>State and Country</r:label>
        <r:text name='billing[state]' /> <r:text name='billing[country]' />
      </li>
      <li>
        <r:label for='billing[postcode]'>Postcode</r:label>
        <r:text name='billing[postcode]' />
      </li>
    </ol>
  </div>
  <r:text name='notes' value="some note"/>
  <ol class="credit_card">
    <li>
      <r:label for='credit_card[name]'>Name on Card</r:label>
      <r:text name='credit_card[name]' />
    </li>
    <li>
      <r:label for='credit_card[number]'>Card</r:label>
      <r:card:type /> <r:text name='credit_card[number]' /> <r:text name='credit_card[verification]' length='4' />
      <r:card:month /> <r:card:year />
    </li>
  </ol>
  <r:form:submit />
</r:shop:cart>
BODY
  end

  def checkout_config
<<-CONFIG
checkout:
  test: true
  gateway:
    name: Bogus
    credentials:
      login: 123456
CONFIG
  end

  helpers do
    def mock_page_with_request_and_data
      @page     = pages(:home)

      @request  = OpenStruct.new({
        :session => {}
      })
      @data     = {}

      stub(@page).data    { @data }
      stub(@page).request { @request }
    end

    def mock_response
      @response = OpenStruct.new({
        :result => {
          :results => {}
        }
      })
      mock(Forms::Tags::Responses).current(anything,anything) { @response }
    end

    def mock_valid_form_checkout_request
      @form = forms(:checkout)
      @form.page = pages(:home)
      @form[:extensions] = {
        :bogus_checkout   => {
          :extension => 'checkout',
          :test      => true,
          :gateway   => {
            :name    => 'Bogus'
          },
          :extensions => {
            :order => {
              :extension => 'mail',
              :subject   => 'new order',
              :from      => 'orders@bogus.com',
              :to        => 'orders@bogus.com'
            },
            :invoice => {
              :extension => 'mail',
              :from      => 'orders@bogus.com',
              :subject   => 'your invoice'
            },
          }
        }
      }

      @data = {
        :credit_card => {
          :number       => '1',
          :name         => 'Mr. Joe Bloggs',
          :verification => '123',
          :month        => 1,
          :year         => 2012,
          :type         => 'visa'
        },
        :notes          => 'some note',
        :options => {
          :address      => {
            :address1   => 'address',
            :zip        => 'zip'
          }
        }
      }

      @request.session = { :shop_order => @order.id }
    end

    def mock_valid_form_address_request
      @form = forms(:checkout)
      @form.page = pages(:home)
      @form[:extensions] = {
        :addresses  => {
          :extension => 'address',
          :billing   => true,
          :shipping  => true
        }
      }

      @data = {
        :billing => {
          :id           => shop_billings(:order_billing).id,
          :name         => shop_billings(:order_billing).name,
          :phone        => shop_billings(:order_billing).phone,
          :email        => shop_billings(:order_billing).email,
          :street_1     => shop_billings(:order_billing).street_1,
          :city         => shop_billings(:order_billing).city,
          :state        => shop_billings(:order_billing).state,
          :country      => shop_billings(:order_billing).country,
          :postcode     => shop_billings(:order_billing).postcode
        },
        :shipping => {
          :id           => shop_shippings(:order_shipping).id,
          :name         => shop_shippings(:order_shipping).name,
          :phone        => shop_shippings(:order_shipping).phone,
          :email        => shop_shippings(:order_shipping).email,
          :street_1     => shop_shippings(:order_shipping).street_1,
          :city         => shop_shippings(:order_shipping).city,
          :state        => shop_shippings(:order_shipping).state,
          :country      => shop_shippings(:order_shipping).country,
          :postcode     => shop_shippings(:order_shipping).postcode
        }
      }

      @request.session = { :shop_order => @order.id }
    end

  end

end