class AddressChanges < ActiveRecord::Migration
  def self.up
    add_column :shop_addresses, :phone, :string
    add_column :shop_addresses, :street_1, :string
    add_column :shop_addresses, :street_2, :string
    add_column :shop_addresses, :of_type, :string
    add_column :shop_addresses, :addressable_id, :id
    add_column :shop_addresses, :addressable_type, :string

    ShopAddress.find_each do |a|
      a.update_attribute(:street_1, a.street)
    end

    # remove_column :shop_addresses, :street
  end

  def self.down
    add_column :shop_addresses, :street, :string

    ShopAddress.find_each do |a|
      a.update_attribute(:street, a.street_1)
    end

    # remove_column :shop_addresses, :phone
    # remove_column :shop_addresses, :street_1
    # remove_column :shop_addresses, :street_2
    # remove_column :shop_addresses, :of_type
    # remove_column :shop_addresses, :shop_addressable_id
    # remove_column :shop_addresses, :shop_addressable_type
  end

end
