require File.dirname(__FILE__) + '/../spec_helper'

describe 'SimpleProductManager' do
	dataset :pages
	dataset :products

	describe '<r:product:find>' do
		it "should use 'where' option correctly" do
			pages(:home).should render('<r:product:find where="price > 10.00" order="title ASC"><r:product:title /></r:product:find>').as('Croissant')
		end
	end
	
	describe '<r:products:each>' do
		it "should itterate over every product by default" do
			# We have 7 products - one dot for each one
			pages(:home).should render('<r:products:each>.</r:products:each>').as('.......')
		end

		it "should order by sequence by default" do
			Product.find(:all).each do |p|
				p.update_attribute(:sequence, Kernel::rand(1000))
			end
			pages(:home).should render('<r:products:each><r:product:title /></r:products:each>').as(Product.find(:all, :order => 'sequence').collect { |x| x.title }.join(''))
		end

		it "should order OK by title" do
			pages(:home).should render('<r:products:each order="title ASC"><r:product:title />,</r:products:each>').as('Caesar Salad,Croissant,Green Salad,Jam Tart,Multigrain,White,Wholemeal,')
		end
		
		it "should order OK by price" do
			pages(:home).should render('<r:products:each order="price DESC"><r:product:title />,</r:products:each>').as('Croissant,Caesar Salad,Green Salad,Jam Tart,White,Wholemeal,Multigrain,')
		end
		
		it "should restrict OK by price" do
			pages(:home).should render('<r:products:each where="price > 3.40" order="price DESC"><r:product:title />,</r:products:each>').as('Croissant,Caesar Salad,Green Salad,Jam Tart,')
		end

		it "should work within category:find" do
			pages(:home).should render('<r:category:find where="title=\'Pastries\'"><r:products:each order="title ASC"><r:product:title />,</r:products:each></r:category:find>').as('Croissant,Jam Tart,')
		end

		it "should work within subcategory:find" do
			c1=Category.create(:title => 'Test Category')
			c2=Category.create(:title => 'Another Category', :parent => c1)
			p=Product.create(:title => 'Bar', :category => c2)
			c2=Category.create(:title => 'Subcategory', :parent => c1)
			p=Product.create(:title => 'Foo', :category => c2)
			pages(:home).should render('<r:category:find where="title=\'Test Category\'"><r:subcategories:each where="title=\'Subcategory\'"><r:products:each order="title ASC"><r:product:title /></r:products:each></r:subcategories:each></r:category:find>').as('Foo')
		end
	end
	
	%w(id title description).each do |type|
		describe "<r:product:#{type}>" do
			it "should work inside of products:each" do
				pages(:home).should render("<r:products:each order=\"title\"><r:product:#{type} />,</r:products:each>").as(Product.find(:all, :order => 'title').collect { |p| p.send(type.to_sym) }.join(',') + ',')
			end
			
			it "should work inside of product" do
				pages(:home).should render("<r:product:find where=\"title='White'\"><r:product:#{type} /></r:product:find>").as(Product.find_by_title('White').send(type.to_sym).to_s)
			end
		end
	end

	describe "<r:product:link>" do
		it "should work inside of product:find" do
			p=Product.find(:first)
			pages(:home).should render("<r:product:find where=\"id=#{p.id}\"><r:product:link><r:product:title /></r:product:link></r:product:find>").as("<a href=\"#{p.url}\">#{p.title}</a>")
		end
		it "should default to the title if no content" do
			p=Product.find(:first)
			pages(:home).should render("<r:product:find where=\"id=#{p.id}\"><r:product:link /></r:product:find>").as("<a href=\"#{p.url}\">#{p.title}</a>")
		end
		it "should work inside of products:each" do
			p=Product.find(:first)
			pages(:home).should render("<r:products:each where=\"id=#{p.id}\"><r:product:link><r:product:title /></r:product:link></r:products:each>").as("<a href=\"#{p.url}\">#{p.title}</a>")
		end

		it "should set a class when the current page" do
			p=Product.find(:first)
			url=p.url
			page=RailsPage.new(:title => 'Product Test', :url => url)
			page.should render("<r:product:find where=\"id=#{p.id}\"><r:product:link><r:product:title /></r:product:link></r:product:find>").as("<a href=\"#{url}\" class=\"current\">#{p.title}</a>")
		end

		it "should set a custom class when provided and selected" do
			p=Product.find(:first)
			url=p.url
			page=RailsPage.new(:title => 'Product Test', :url => url)
			page.should render("<r:product:find where=\"id=#{p.id}\"><r:product:link selected=\"hilight\"><r:product:title /></r:product:link></r:product:find>").as("<a href=\"#{url}\" class=\"hilight\">#{p.title}</a>")
		end
	end
	
	describe '<r:product:price>' do
		it "should work inside of products:each" do
			pages(:home).should render("<r:products:each order=\"price ASC\"><r:product:price />,</r:products:each>").as('$3.00,$3.10,$3.20,$3.50,$7.00,$9.00,$4,000.00,')
		end
		
		it "should display in $0.00 format by default" do
			pages(:home).should render("<r:product:find where=\"title='Croissant'\"><r:product:price /></r:product:find>").as('$4,000.00')
		end
		
		it "should display in custom format if asked" do
			pages(:home).should render("<r:product:find where=\"title='Croissant'\"><r:product:price precision=\"1\" unit=\"%\" separator=\"-\" delimiter=\"|\"/></r:product:find>").as('%4|000-0')
		end
	end
	
	describe "<r:product:field>" do
		before do
			@p=Product.create(:title => "Test", :category => Category.find(:first))
			@p.json_field_set(:fieldname, "Foo")
			@p.save!
		end

		it "should fetch existing data OK" do
			pages(:home).should render("<r:product:find where=\"title='Test'\"><r:product:field name=\"fieldname\" /></r:product:find>").as("Foo")
		end

		it "should return nothing on missing data" do
			pages(:home).should render("<r:product:find where=\"title='Test'\">-<r:product:field name=\"missing_field\" />-</r:product:find>").as("--")
		end
	end

	describe "<r:product:if>" do
		it "should match by title" do
			pages(:home).should render('<r:products:each order="title ASC"><r:product:if title="Croissant"><r:product:title /></r:product:if></r:products:each>').as('Croissant')
		end
		it "should match by id" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:products:each order=\"title ASC\"><r:product:if id=\"#{p.id}\"><r:product:title /></r:product:if></r:products:each>").as('Croissant')
		end
		it "should match within find" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:product:find id=\"#{p.id}\"><r:product:if id=\"#{p.id}\"><r:product:title /></r:product:if></r:product:find>").as('Croissant')
		end
		it "should suppress content when no match within find" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:product:find id=\"#{p.id}\">-<r:product:if title=\"Something Different\"><r:product:title /></r:product:if>-</r:product:find>").as('--')
		end
	end

	describe "<r:product:unless>" do
		it "should match by title" do
			pages(:home).should render('<r:products:each order="title ASC"><r:product:unless title="Croissant"><r:product:title /></r:product:if></r:products:each>').as('Caesar SaladGreen SaladJam TartMultigrainWhiteWholemeal')
		end
		it "should match by id" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:products:each order=\"title ASC\"><r:product:unless id=\"#{p.id}\"><r:product:title /></r:product:unless></r:products:each>").as('Caesar SaladGreen SaladJam TartMultigrainWhiteWholemeal')
		end
		it "should restrict content when no match within find" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:product:find id=\"#{p.id}\">-<r:product:unless id=\"#{p.id}\"><r:product:title /></r:product:unless>-</r:product:find>").as('--')
		end
		it "should match within find" do
			p=Product.find_by_title('Croissant')
			pages(:home).should render("<r:product:find id=\"#{p.id}\">-<r:product:unless title=\"Something Different\"><r:product:title /></r:product:unless>-</r:product:find>").as('-Croissant-')
		end
	end
end
