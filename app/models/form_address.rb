class FormAddress
  include Forms::Models::Extension
  include Shop::Models::FormExtension

  attr_accessor :config, :data, :result, :gateway, :card, :billing, :shipping

  def create
    find_current_order      # locate the @order object

    create_result_object    # A default response object

    create_order_addresses  # Process the addresses

    @result
  end

  protected

  def create_result_object
    @result = {
      :order    => @order.id,
      :billing  => nil,
      :shipping => nil
    }
  end

  def create_order_addresses
    if billing?
      create_order_billing_address
    end

    create_order_shipping_address

    unless (@billing.present? and @billing.valid?) and (@shipping.present? and @shipping.valid?)
      @form.redirect_to = :back
    end

    @result[:billing]  = (@billing.valid?  ? @billing.id  : false) rescue false
    @result[:shipping] = (@shipping.valid? ? @shipping.id : false) rescue false
  end

  def create_order_billing_address
    if @order.billing.present?
      @billing = @order.billing
      @billing.update_attributes(billing)

    else
      @billing = ShopBilling.new(billing)
      if @billing.save
        @order.update_attribute(:billing, @billing)
      end

    end
  end

  def create_order_shipping_address
    if shipping?
      if @order.shipping.present?
        @shipping = @order.shipping
        @shipping.update_attributes(shipping)

      else
        @shipping = ShopShipping.new(shipping)
        if @shipping.save
          @order.update_attribute(:shipping, @shipping)
        end

      end
    else
      if @order.shipping.present?
        @shipping = @order.shipping

      else
        if @order.shipping.nil?
          @shipping = ShopShipping.new(@billing.attributes)
          if @shipping.save
            @order.update_attribute(:shipping, @shipping)
          end
        end
      end

    end
  end

  # Returns an array of billing attributes
  def billing
    @data[:billing]
  end

  # Returns an array of shipping attributes
  def shipping
    @data[:shipping]
  end

  # Returns whether form is configured for billing
  def billing?
    @config[:billing].present? and billing.present?
  end

  # Returns whether form is configured for shipping
  def shipping?
    @config[:shipping].present? and shipping.present?
  end

end