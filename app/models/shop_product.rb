class ShopProduct < ActiveRecord::Base

  default_scope :joins => :page, :order => 'pages.position ASC'

  belongs_to  :page,        :dependent  => :destroy
  belongs_to  :created_by,  :class_name => 'User'
  belongs_to  :updated_by,  :class_name => 'User'

  has_many    :line_items,  :class_name => 'ShopLineItem',  :foreign_key  => :item_id,      :dependent => :destroy
  has_many    :orders,      :class_name => 'ShopOrder',     :through      => :line_items,   :uniq      => true

  has_many    :attachments, :through => :page

  before_validation             :assign_slug, :assign_breadcrumb, :assign_page_class_name
  validates_presence_of         :page

  validates_numericality_of     :price, :greater_than_or_equal_to => 0.00, :allow_nil => false, :precisions => 2

  accepts_nested_attributes_for :page

  # Returns the title of the product's page
  def name; page.title; end

  # Returns the url of the page formatted as an sku
  def sku; ShopProduct.to_sku(slug); end

  # Returns the url of the product's page
  def url; page.url; end

  # Returns category through the pages parent
  def category; page.parent.shop_category; end

  # Returns id of category
  def category_id; category.id; end

  # Returns the content of the product's page's description part
  def description
    page.render_part('description')
  end

  # Returns the url of the page
  def url; page.url; end

  # Returns the customers of this product
  def customers; line_items.map(&:customer).flatten.compact.uniq; end

  # Returns an array of customer ids
  def customer_ids; customers.map(&:id); end

  # Return an array of the pages images
  def images; page.images; end

  # Returns an array of image ids
  def image_ids; images.map(&:id); end

  # Returns images not attached to product
  def available_images; Image.all - images; end

  # Returns the page slug
  def slug; page.slug; end

  # Overloads the base to_json to return what we want
  def to_json(*attrs); super self.class.params; end

  # Applies an array of variant names as product_variants
  def apply_variant_template(variant)
    result = true
    variant.options.each do |variant|
      variants.new(:name => variant).save! rescue (result = false)
    end
    result
  end

  class << self

    # Sorts products within a category
    def sort(category_id, product_ids)
      parent_id = ShopCategory.find(category_id).page_id

      product_ids.each_with_index do |id, index|
        ShopProduct.find(id).page.update_attributes!(
          :position  => index+1,
          :parent_id => parent_id
        )
      end
    end

    # Returns attributes attached to the product
    def attrs
      [ :id, :price, :page_id, :created_at, :updated_at ]
    end

    # Returns methods with usefuly information
    def methds
      [ :category_id, :name, :description, :handle, :url, :customer_ids, :image_ids, :created_at, :updated_at ]
    end

    # Returns a custom hash of attributes on the product
    def params
      { :only  => self.attrs, :methods => self.methds }
    end

    # Converts a url to a pretty sku and removes the shop prefix /shop/page/category/product page-category-product
    def to_sku(url)
      if url.present?
        url.downcase.strip.gsub(/[^a-zA-Z0-9_]/,"_")
      end
    end

  end

  protected

  # Assigns a slug to a page if its not set
  def assign_slug
    if page.present?
      self.page.slug = ShopProduct.to_sku(page.slug.present? ? page.slug : page.title)
    end
  end

  # Assigns a breadcrumb to the page if its not set
  def assign_breadcrumb
    if page.present?
      self.page.breadcrumb ||= page.title
    end
  end

  # Assigns a page class if its nil
  def assign_page_class_name
    if page.present?
      self.page.class_name = page.class_name || 'ShopProductPage'
    end
  end

end
