require File.dirname(__FILE__) + '/../spec_helper'

describe ShopCategory do
  before(:each) do
    Category.destroy_all
    @category = Category.new(:title => 'Test')
  end

  it "should be valid" do
    @category.should be_valid
  end

  it "should set tags for DB in correct format from tag_names" do
    @category.tag_names='Foo, Bar'
    @category.tags.should == ',Foo,Bar,'
    @category.tag_names='Bletch Blomb'
    @category.tags.should == ',Bletch Blomb,'
    @category.tag_names=[ 'Foo', 'Bar', 'Bletch Blomb' ]
    @category.tags.should == ',Foo,Bar,Bletch Blomb,'
    @category.tag_names=''
    @category.tags.should == ''
    @category.tag_names=nil
    @category.tags.should == ''
  end

  it "should return tags in human format from tag_names" do
    @category.tags=',Foo,Bar,Bletch Blomb,'
    @category.tag_names.should == 'Foo, Bar, Bletch Blomb'
    @category.tags=nil
    @category.tag_names.should == ''
  end

  it "should handle subcategories" do
    p=Category.new(:title => 'Parent Category')
    p.save
    c1=Category.new(:title => 'Child1', :parent_id => p.id)
    c2=Category.new(:title => 'Child2', :parent => p)
    c1.save; c2.save

    p.subcategories.size.should == 2
    c1.parent.id.should == p.id
    c2.parent.id.should == p.id
  end

  it "should respond to find_all_except" do
    Category.delete_all
    %w( Test1 Test2 Test3 Test4 ).each do |title|
      Category.new(:title => title).save
    end
    c=Category.find(:first)
    Category.find_all_except(c).should_not include(c)
    Category.find_all_except(c).size.should == 3
  end

  it "should return the category heirachy in to_s" do
    c1=Category.create(:title => "Test1")
    c2=Category.create(:title => "Test2", :parent => c1)
    c3=Category.create(:title => "Test3", :parent => c2)
    c1.to_s.should == 'Test1'
    c2.to_s.should == 'Test1 > Test2'
    c3.to_s.should == 'Test1 > Test2 > Test3'
  end

  it "should find all top level Categories with no parents" do
    Category.delete_all
    c1=Category.create(:title => 'Test1')
    c2=Category.create(:title => 'Test2', :parent => c1)
    Category.find_all_top_level.should_not include(c2)
    Category.find_all_top_level.size.should == 1
  end

  describe "sequencing" do
    before do
      @c1=@category.clone
      @c1.title='Alpha'
      @c2=@category.clone
      @c2.title='Bravo'
      @c3=@category.clone
      @c3.title='Charlie'
      @c1.save; @c2.save; @c3.save
      @s1=@category.clone
      @s1.parent_id=@c1.id
      @s1.save
    end

    it "should assign sequences by default" do
      @c1.sequence.should == 1
      @c2.sequence.should == 2
      @c3.sequence.should == 3
      # Sequence is scoped to parent_id
      @s1.sequence.should == 1
    end

    it "should resolve conflicting sequences" do
      c4=@category.clone
      c4.title='Delta'
      c4.sequence=2
      c4.save
      @c1.reload; @c2.reload; @c3.reload; @s1.reload
      @c1.sequence.should == 1
      c4.sequence.should == 2
      @c2.sequence.should == 3
      @c3.sequence.should == 4
      # Sequence should not be messed with for separate parent_ids
      @s1.sequence.should == 1
    end

    it "should not regenerate on deletion" do
      @c2.destroy
      @c1.reload; @c3.reload; @s1.reload
      @c1.sequence.should == 1
      @c3.sequence.should == 3
      # Sequence should not be messed with for separate parent_ids
      @s1.sequence.should == 1
    end

    it "should regenerate to fill gaps on next creation" do
      @c2.destroy
      @c1.reload; @c3.reload
      c4=@category.clone
      c4.title='Delta'
      c4.save
      @c1.reload; @c3.reload; @s1.reload
      @c1.sequence.should == 1
      @c3.sequence.should == 2
      c4.sequence.should == 3
      # Sequence should not be messed with for separate parent_ids
      @s1.sequence.should == 1
    end


  end

  describe "instance" do
    before do
      @category.save
    end

    it "should generate a valid parameter string" do  
      @category.to_param.should =~ /^\d+-[A-Za-z0-9\-]+/
    end

    it "should generate a valid url" do
      @category.url.should == "/products/#{@category.to_param}"
    end
  end
  
  describe ".layout" do
    it "should return default values" do
      c=Category.create(:title => "Test")
      c.layout.should == 'Category'
    end
    it "should return set value" do
      c=Category.create(:title => "Test", :custom_layout => 'CustomCategoryLayout')
      c.layout.should == 'CustomCategoryLayout'
    end
    it "should inherit from parent Category" do
      c1=Category.create(:title => "Foo", :custom_layout => 'CustomCategoryLayout')
      c2=Category.create(:title => "Bar", :parent => c1)
      c2.layout.should == 'CustomCategoryLayout'
    end
  end

  describe ".product_layout" do
    it "should return default values" do
      c=Category.create(:title => "Test")
      c.product_layout.should == 'Product'
    end
    it "should return set value" do
      c=Category.create(:title => "Test", :custom_product_layout => 'CustomProductLayout')
      c.product_layout.should == 'CustomProductLayout'
    end
    it "should inherit from parent Category" do
      c1=Category.create(:title => "Foo", :custom_product_layout => 'CustomProductLayout')
      c2=Category.create(:title => "Bar", :parent => c1)
      c2.product_layout.should == 'CustomProductLayout'
    end
  end

end
