class ShopCustomersDataset < Dataset::Base

  def load
    create_model :shop_customer, :customer,
      :name     => 'customer',
      :email    => 'customer@example.com',
      :login    => 'customer',
      :password => 'radiant',
      :password_confirmation => 'radiant'

    create_model :shop_customer, :bad_customer,
      :name     => 'bad customer',
      :email    => 'bad_customer@example.com',
      :login    => 'bad customer',
      :password => 'radiant',
      :password_confirmation => 'radiant'
  end

  helpers do
    def login_as(user)
      login_user = users(user)
      flunk "Can't login as non-existing user #{user.to_s}." unless login_user
      UserActionObserver.current_user = login_user
      login_user
    end

    def logout
      UserActionObserver.current_user = nil
    end
  end
end
