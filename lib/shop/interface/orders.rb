module Shop
  module Interface
    module Orders

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        attr_accessor :orders

        protected

        def load_default_shop_orders_regions
          returning OpenStruct.new do |orders|
            orders.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{head form popups}
              edit.form.concat %w{inputs meta parts foot}
              edit.foot.concat %w{buttons timestamp}
            end
            orders.new = orders.edit
            orders.index = Radiant::AdminUI::RegionSet.new do |index|
              index.head.concat %w{}
              index.body.concat %w{price status updated customer}
              index.foot.concat %w{buttons pagination}
            end
            orders.remove = orders.index
          end
        end
      end

    end
  end
end