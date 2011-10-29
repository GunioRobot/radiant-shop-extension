class ShopShipping < ShopAddress

  default_scope :conditions => { :of_type => 'shipping' }

end