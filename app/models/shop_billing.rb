class ShopBilling < ShopAddress

  default_scope :conditions => { :of_type => 'billing' }

  validates_presence_of :email

end