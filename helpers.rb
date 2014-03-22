def set_playername(playername, remember_name)
  if params[:playername].empty?
    session[:playername] = "Player"
  else
    session[:playername] = params[:playername]
  end

  if remember_name == 'on' || remember_name == '1' || remember_name == 'true'
    session[:playername_persistent] = true
  end

end

def build_deck
  cards = []
  amount_decks = 1
  
  # For each amount_decks, create the deck using an array of suits and an array of values
  amount_decks.times do
    ['hearts','diamonds','spades','clubs'].each do |suit|
      ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king'].each do |value|
        cards << {suit: suit, value: value}
      end
    end
  end

  cards.shuffle!
  session[:deck] = cards
end

def setup
  session[:player_cards] = []
  session[:dealer_cards] = []

  2.times { session[:player_cards] << session[:deck].pop }
  2.times { session[:dealer_cards] << session[:deck].pop }
  
  session[:dealer_cards].last[:hidden] = true
end

def has_hidden_card(cards)
  cards.select {|card| card[:hidden] }.size > 0
end

def cards_value(cards)
  total_points = 0

  cards.each do |card| 

    if card[:value].to_i != 0
      point = card[:value].to_i
    else
      point = case card[:value]
                when 'ace'; 11
                when 'jack', 'queen', 'king'; 10
              end
    end

    total_points += point
  end

  # Take into account any aces if the total value is higher then 21
  cards.select{ |card| card[:value] == 'ace' }.count.times do
    total_points -= 10 if total_points > 21
  end

  total_points
end

def card_filename(card)
  base_path = '/images/cards'
  if card[:hidden]
    return "#{base_path}/cover.jpg"
  else
    return "#{base_path}/#{card[:suit]}_#{card[:value]}.jpg"
  end
end

def card_title(card)
  if card[:hidden]
    return 'Nobody knows'
  else
    card_value = card[:value].to_i == 0 ? card[:value] : CARD_VALUE_TO_WORD[card[:value].to_i]

    return "#{card_value.capitalize} of #{card[:suit].capitalize}"
  end
end

def reset_game
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:deck] = []
  session[:state] = nil
end
