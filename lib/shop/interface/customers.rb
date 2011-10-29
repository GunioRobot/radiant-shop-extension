module Shop
  module Interface
    module Customers

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        attr_accessor :customers

        protected

        def load_default_shop_customers_regions
          returning OpenStruct.new do |customers|
            customers.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{head form popups}
              edit.form.concat %w{inputs meta parts foot}
              edit.foot.concat %w{buttons timestamp}
            end
            customers.new = customers.edit
            customers.index = Radiant::AdminUI::RegionSet.new do |index|
              index.head.concat %w{buttons}
              index.body.concat %w{name modify}
              index.foot.concat %w{buttons pagination}
            end
            customers.remove = customers.index
          end
        end
      end

    end
  end
end