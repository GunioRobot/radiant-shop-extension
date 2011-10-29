module Shop
  module Interface
    module Discounts

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        attr_accessor :discounts

        protected

        def load_default_shop_discounts_regions
          returning OpenStruct.new do |discounts|
            discounts.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{head form popups}
              edit.form.concat %w{inputs meta parts foot}
              edit.foot.concat %w{buttons timestamp}
            end
            discounts.new = discounts.edit
            discounts.index = Radiant::AdminUI::RegionSet.new do |index|
              index.head.concat %w{}
              index.body.concat %w{name code amount modify}
              index.foot.concat %w{buttons}
            end
            discounts.remove = discounts.index
          end
        end
      end

    end
  end
end