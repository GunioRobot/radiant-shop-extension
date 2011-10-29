require File.dirname(__FILE__) + "/../../../spec_helper"

describe Admin::Shop::CustomersController do

  dataset :shop_customers, :users

  before(:each) do
    login_as  :admin
  end

  describe '#new' do
    context 'instance variables' do
      it 'should be assigned' do
        get :new

        assigns(:inputs).should   include('name','email')
        assigns(:meta).should     include('login','password','password_confirmation')
        assigns(:buttons).should  include()
        assigns(:parts).should    include()
        assigns(:popups).should   include()
      end
    end
  end

  describe '#edit' do
    context 'instance variables' do
      it 'should be assigned' do
        get :edit, :id => shop_customers(:customer).id

        assigns(:inputs).should   include('name','email')
        assigns(:meta).should     include('login','password','password_confirmation')
        assigns(:buttons).should  include()
        assigns(:parts).should    include('orders','addresses')
        assigns(:popups).should   include()
      end
    end
  end

  describe '#create' do
    context 'instance variables' do
      it 'should be assigned' do
        post :create, :shop_customer => {}

        assigns(:inputs).should   include('name','email')
        assigns(:meta).should     include('login','password','password_confirmation')
        assigns(:buttons).should  include()
        assigns(:parts).should    include()
        assigns(:popups).should   include()
      end
    end
  end

  describe '#update' do
    context 'instance variables' do
      it 'should be assigned' do
        put :update, :id => shop_customers(:customer).id, :shop_customer => {}

        assigns(:inputs).should   include('name','email')
        assigns(:meta).should     include('login','password','password_confirmation')
        assigns(:buttons).should  include()
        assigns(:parts).should    include('orders','addresses')
        assigns(:popups).should   include()
      end
    end
  end

end