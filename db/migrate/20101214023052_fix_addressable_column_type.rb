class FixAddressableColumnType < ActiveRecord::Migration
  def self.up
    add_column :shop_addresses, :addressable_integer, :integer
    ShopAddress.reset_column_information
    ShopAddress.find_each do |address|
      address.update_attribute(:addressable_integer, :addressable_id)
    end

    begin
      remove_column :shop_addresses, :addressable_id
      add_column :shop_addresses, :addressable_id, :integer
      ShopAddress.reset_column_information
      ShopAddress.find_each do |address|
        address.update_attribute(:addressable_id, :addressable_integer)
      end

      remove_column :shop_addresses, :addressable_integer
    rescue
      # Yay sqlite
    end

  end

  def self.down
    # no reverse
  end
end
