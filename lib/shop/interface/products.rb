module Shop
  module Interface
    module Products

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        attr_accessor :products

        protected

        def load_default_shop_products_regions
          returning OpenStruct.new do |products|
            products.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{head form popups}
              edit.form.concat %w{inputs meta parts foot}
              edit.foot.concat %w{buttons timestamp}
            end
            products.new = products.edit
            products.index = Radiant::AdminUI::RegionSet.new do |index|
              index.head.concat     %w{}
              index.category.concat %w{move name handle modify}
              index.products.concat %w{body}
              index.product.concat  %w{move icon name sku price modify}
              index.foot.concat     %w{buttons}
            end
            products.remove = products.index
          end
        end
      end

    end
  end
end