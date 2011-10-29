class SetupShop < ActiveRecord::Migration
  def self.up
    create_table "shop_products", :force => true do |t|
      t.decimal  "price"
      t.decimal  "weight"
      t.decimal  "height"
      t.decimal  "width"
      t.decimal  "depth"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.integer  "page_id"
    end

    create_table "shop_categories", :force => true do |t|
      t.integer  "product_layout_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.integer  "page_id"
    end

    create_table "shop_product_attachments", :force => true do |t|
      t.integer "position",      :default => 1
      t.integer "image_id"
      t.integer "product_id"
      t.integer "created_by_id"
      t.integer "updated_by_id"
    end
    add_index "shop_product_attachments", ["image_id"],   :name => "index_shop_product_attachments_on_image_id"
    add_index "shop_product_attachments", ["position"],   :name => "index_shop_product_attachments_on_position"
    add_index "shop_product_attachments", ["product_id"], :name => "index_shop_product_attachments_on_product_id"

    create_table "shop_orders", :force => true do |t|
      t.text     "notes"
      t.string   "status",      :default => "new"
      t.integer  "billing_id"
      t.integer  "shipping_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "customer_id"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end
    add_index "shop_orders", ["customer_id"], :name => "index_shop_orders_on_customer_id"
    add_index "shop_orders", ["status"], :name => "index_shop_orders_on_status"

    create_table "shop_line_items", :force => true do |t|
      t.integer  "quantity",      :default => 1
      t.integer  "item_id"
      t.string   "item_type"
      t.decimal  "item_price"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "order_id"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end
    add_index "shop_line_items", ["item_id"], :name => "index_shop_line_items_on_item_id"
    add_index "shop_line_items", ["order_id"], :name => "index_shop_line_items_on_order_id"

    create_table "shop_addresses", :force => true do |t|
      t.string   "email"
      t.string   "name"
      t.string   "unit"
      t.string   "street"
      t.string   "city"
      t.string   "state"
      t.string   "postcode"
      t.string   "country"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "shop_payments", :force => true do |t|
      t.float    "amount"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "gateway"
      t.string   "card_type"
      t.string   "card_number"
      t.integer  "order_id"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    add_index "shop_payments", ["gateway"],  :name => "index_shop_payments_on_gateway"
    add_index "shop_payments", ["order_id"], :name => "index_shop_payments_on_order_id"
  end
end
