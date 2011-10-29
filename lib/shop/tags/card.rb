module Shop
  module Tags
    module Card

      CARD_TYPES = {
        'visa'    => 'Visa',
        'master'  => 'Master Card',
        'diners'  => 'Diners Club',
        'amex'    => 'American Express'
      }

      include Radiant::Taggable

      tag 'form:card' do |tag|
        tag.expand
      end

      # Outputs a list of credit card types
      desc %{ Outputs a list of credit card types }
      tag 'form:card:type' do |tag|
        content = %{<div id="credit_card_type">\n}
        cards = {}
        cards.merge! CARD_TYPES

        cards.reject! { |k,v| tag.attr['except'].split(',').include? k } if tag.attr['except'].present?
        cards.reject! { |k,v| !tag.attr['only'].split(',').include? k  }if tag.attr['only'].present?

        cards.sort.reverse.each do |k, v|
          content << %{<input name="credit_card[type]" id="credit_card_#{k}" type="radio" value="#{k}"/>\n}
          content << %{<label for="credit_card_#{k}" class="#{k} credit_card" id="credit_card_#{k}_label">#{v}</label>\n}
        end

        content << %{</div>}
      end

      # Outputs a list of months for credit cards
      desc %{ Outputs a list of months for credit cards }
      tag 'form:card:month' do |tag|
        content = %{<select name="credit_card[month]" id="credit_card_month">\n}
          Date::MONTHNAMES[1,12].each_with_index do |name,index|
            month = sprintf('%02d', index+1)
            content << %{<option value="#{month}">#{month} - #{name}</option>\n}
          end
        content << %{</select>}
      end

      # Ouputs a list of years for credit cards
      desc %{ Ouputs a list of years for credit cards }
      tag 'form:card:year' do |tag|
        content = %{<select name="credit_card[year]" id="credit_card_year">\n}
          (Time.zone.now.year ... Time.zone.now.year + 15).each do |year|
            content << %{<option value="#{year}">#{year}</option>\n}
          end
        content << %{</select>}
      end

    end
  end
end