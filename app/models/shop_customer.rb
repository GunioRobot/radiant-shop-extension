class ShopCustomer < User

  include Users::Models::User::Scoped

  def first_name
    name = ''

    names = self.name.split(' ')
    if names.length > 1
      name = names[0, names.length-1].join(' ')
    else
      name = names.join(' ')
    end

    name
  end

  def last_name
    name = ''

    names = self.name.split(' ')
    if names.length > 1
      name = names[-1]
    end

    name
  end

end