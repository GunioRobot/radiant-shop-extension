class ShopPayment < ActiveRecord::Base

  belongs_to :order,  :class_name => 'ShopOrder'

  validates_presence_of :amount
  validates_presence_of :card_type
  validates_presence_of :card_number

end
