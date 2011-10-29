unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require ENV["RADIANT_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{RADIANT_ROOT}/spec/spec_helper"

unless defined? SHOP_ROOT

  SHOP_ROOT = ShopExtension.root + '/spec'

  Dataset::Resolver.default << (SHOP_ROOT + "/datasets")

  if File.directory?(SHOP_ROOT + "/matchers")
    Dir[SHOP_ROOT + "/matchers/**/*.rb"].each {|file| require file }
  end

  Spec::Runner.configure do |config|
    config.mock_with :rr
  end

end