module ShopHelper
  def input_currency(amount)
    number_to_currency(amount, :unit => '', :delimiter => '')
  end

  def routes_to_js(routes)
    js = "ROUTES = new Array;\n"
    @routes.each do |route|
      js << "ROUTES[#{route[:name].to_json}] = #{route[:path].to_json}\n"
    end
    javascript_tag js
  end
end