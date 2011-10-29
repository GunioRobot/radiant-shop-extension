class ShopOrder < ActiveRecord::Base

  default_scope :order => 'shop_orders.updated_at DESC'

  has_one    :payment,      :class_name => 'ShopPayment',   :foreign_key => :order_id,  :dependent => :destroy
  has_many   :line_items,   :class_name => 'ShopLineItem',  :foreign_key => :order_id,  :dependent => :destroy

  belongs_to :created_by,   :class_name => 'User'
  belongs_to :updated_by,   :class_name => 'User'
  belongs_to :customer,     :class_name => 'User',          :foreign_key => :customer_id

  has_one    :billing,      :class_name => 'ShopBilling',   :as => :addressable
  has_one    :shipping,     :class_name => 'ShopShipping',  :as => :addressable

  accepts_nested_attributes_for :line_items,  :reject_if => :all_blank
  accepts_nested_attributes_for :billing,     :reject_if => :all_blank
  accepts_nested_attributes_for :shipping,    :reject_if => :all_blank

  def price
    price = 0; line_items.map { |l| price += l.price }

    price += tax if Radiant::Config['shop.tax_strategy'] === 'exclusive'

    price
  end

  def weight
    weight = 0; line_items.map { |l| weight += l.weight }
    weight
  end

  def tax
    price      = 0; line_items.map { |l| price += l.price; }
    tax        = 0
    percentage = Radiant::Config['shop.tax_percentage'].to_f * 0.01

    case Radiant::Config['shop.tax_strategy']
    when 'inclusive'
      tax = price - (price / (1 + percentage))
    when 'exclusive'
      tax = price * percentage
    end

    BigDecimal.new(tax.to_s)
  end

  def add!(id, quantity = nil, type = nil)
    result = true

    begin
      line_item = line_items.find(id)
      quantity = line_item.quantity + quantity.to_i

      modify!(id,quantity)
    rescue
      quantity  ||= 1
      type      ||= 'ShopProduct'

      if line_items.exists?({:item_id => id, :item_type => type})
        line_item = line_items.first(:conditions => {:item_id => id, :item_type => type})
        quantity  = line_item.quantity + quantity.to_i

        modify!(line_item.id, quantity)
      else
        line_items.create!({:item_id => id, :item_type => type, :quantity => quantity})
      end
    end

    result
  end

  def add(*attrs)
    add!(*attrs)
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    false
  end

  def modify!(id, quantity = 1)
    quantity = quantity.to_i
    if quantity <= 0
      remove!(id)
    else
      line_item = line_items.find(id)
      line_item.update_attributes! :quantity => quantity
    end
  end

  def modify(*attrs)
    modify!(*attrs)
    true
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    false
  end

  def remove!(id)
    line_item = line_items.find(id)
    line_item.destroy

    true
  end

  def remove(*attrs)
    remove!(*attrs)
    true
  rescue ActiveRecord::RecordNotFound
    false
  end

  def clear!
    line_items.destroy_all
  end

  def quantity
    self.line_items.sum(:quantity)
  end

  def new?
    self.status === 'new'
  end

  def paid?
    return false unless self.payment.present?
    self.payment.amount === self.price and self.status === 'paid'
  end

  def shipped?
    self.status === 'shipped'
  end

  class << self

    # A hookable method used by the site controller
    def find_by_session(session)
      find(session)
    end

    # Will scope the contained find calls to a specific status
    def scope_by_status(status)
      case status
      when 'new', 'shipped', 'paid'
        with_scope(:find => { :conditions => {:status => status}}) do
          yield
        end
      else
        yield
      end
    end

    def params
      [ :id, :notes, :status ]
    end
  end

end
