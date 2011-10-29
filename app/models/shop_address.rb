class ShopAddress < ActiveRecord::Base

  belongs_to :addressable, :polymorphic => true

  validates_presence_of :name
  validates_presence_of :street_1
  validates_presence_of :city
  validates_presence_of :postcode
  validates_presence_of :state
  validates_presence_of :country

end
