require 'rubygems'
require 'sinatra'
require 'pry'
require './helpers'

set :sessions, true
set :session_secret, 'Woof Woof!'

CARD_VALUE_TO_WORD = { 2 => "two", 3 => "three", 4 => "four", 5 => "five", 6 => "six", 7 => "seven", 8 => "eight", 9 => "nine", 10 => "ten" }

get '/' do
  erb :index
end

get '/player' do
  erb :'player/info'
end

get '/start' do
  session[:getready] = 0
  reset_game

  if session[:playername_persistent]
    redirect '/get_ready'
  end

  erb :'preparation/playername'
end

post '/playername' do
  set_playername(params[:playername], params[:remember_name])

  redirect '/get_ready'
end

get '/get_ready' do
  if session[:skip_get_ready]
    redirect '/game'
  end

  percentage = 0
  if session[:getready]
    percentage = session[:getready]
  end

  if percentage >= 100
    redirect '/game'
  else
    session[:getready] = (percentage += 20)
    erb :'preparation/getready'
  end

end


get '/game' do
  if session[:player_cards].empty?
    build_deck
    setup
    session[:state] = :player
    session[:skip_get_ready] = true
  end

  if cards_value(session[:dealer_cards]) == 21
    session[:state] = :dealer_blackjack
    @alert_error = "Dealer has backjack, you've lost!!" + play_again

  elsif cards_value(session[:player_cards]) == 21
    session[:state] = :player_blackjack
    @alert_success = "You've blackjack, you win!!" + play_again
  end

  erb :'game/display'
end

post '/game' do
  if params['action'] == 'Hit'
    session[:player_cards] << session[:deck].pop

    if cards_value(session[:player_cards]) > 21
      session[:state] = :player_busted
      @alert_error = "Game over! You've busted!" + play_again
    end

  elsif params['action'] == 'Stay'
    session[:state] = :dealer
    session[:dealer_cards].each {|card| card[:hidden] = false}

  elsif params['action'] == 'Dealer\'s turn'
    if cards_value(session[:dealer_cards]) < 17
      session[:dealer_cards] << session[:deck].pop

    elsif cards_value(session[:player_cards]) > cards_value(session[:dealer_cards])
      session[:state] = :player_wins
      @alert_success = "You win!" + play_again
    elsif cards_value(session[:player_cards]) < cards_value(session[:dealer_cards])
      session[:state] = :dealer_wins
      @alert_error = "Too bad, dealer wins!" + play_again
    else cards_value(session[:player_cards]) == cards_value(session[:dealer_cards])
      session[:state] = :result_tie
      @alert_info = "Game ends in a tie! " + play_again
    end

    if session[:state] == :dealer && cards_value(session[:dealer_cards]) > 21
      session[:state] = :dealer_busted
      @alert_success = "Dealer busted! You win!" + play_again
    end

  end

  erb :'game/display'
end