module Shop
  module Interface
    module Categories

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        attr_accessor :categories

        protected

        def load_default_shop_categories_regions
          returning OpenStruct.new do |categories|
            categories.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{head form popups}
              edit.form.concat %w{inputs meta parts foot}
              edit.foot.concat %w{buttons timestamp}
            end
            categories.new = categories.edit
            categories.remove = categories.index
          end
        end
      end

    end
  end
end