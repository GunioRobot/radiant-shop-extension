module Shop
  module Tags
    module Core
      include Radiant::Taggable

      tag 'shop' do |tag|
        tag.expand
      end

    end
  end
end