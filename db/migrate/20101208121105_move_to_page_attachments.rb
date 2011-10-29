class ShopProductAttachment < ActiveRecord::Base
  belongs_to :product, :class_name => 'ShopProduct'
  belongs_to :image
end

class MoveToPageAttachments < ActiveRecord::Migration
  def self.up
    ShopProductAttachment.find_each do |a|
      Attachment.create(:image => a.image, :page => a.product.page) rescue nil
    end
    drop_table :shop_product_attachments
  end

  def self.down
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

    Attachment.find_each do |a|
      if a.page.shop_product
        ShopProductAttachment.create(:image => a.image, :product => a.page.shop_product)
      end
    end

  end
end
