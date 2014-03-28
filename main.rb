require 'rubygems'
require 'sinatra'
require 'pry'
require './helpers'

set :sessions, true
set :session_secret, 'Codefish.org\'s secret'

CARD_VALUE_TO_WORD = { 2 => "two", 3 => "three", 4 => "four", 5 => "five", 6 => "six", 7 => "seven", 8 => "eight", 9 => "nine", 10 => "ten" }

helpers do
  def helper_method()
    puts 'this is a helper method'
  end
end

before do
  # puts 'this code is run before every other get/post below'
end

get '/' do
  remove_game
  erb :index
end

get '/player' do
  erb :'player/info'
end

get '/start' do
  session[:getready] = 0
  reset_game

  if session[:playername_persistent]
    redirect '/make_bet'
  end

  erb :'preparation/playername'
end

post '/playername' do
  if params[:playername].empty? 
    @alert_error = "Please enter a valid name. I'm sure you have one :-)"
    halt erb :'preparation/playername'
  end

  set_playername(params[:playername], params[:remember_name])

  redirect '/make_bet'
end

get '/make_bet' do
  reset_round
  if session[:player_money] > 0
    erb :'preparation/make_bet'
  else
    erb :'game/game_over'
  end
end

post '/make_bet' do
  if params['bet_amount'].empty? || params['bet_amount'].to_i <= 0
    @alert_error = "Illegal amount entered. Please enter a valid number."
    erb :'preparation/make_bet'

  elsif params['bet_amount'].to_i > session[:player_money]
    @alert_error = "I'm sorry, you don't have this much money to bet. Specify a lower amount."
    erb :'preparation/make_bet'

  else 
    session[:player_bet] = params['bet_amount'].to_i
    session[:player_money] -= session[:player_bet]
    
    redirect '/game'
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

  if [:player_wins, :dealer_wins, :result_tie, :dealer_busted, :player_busted].include? session[:state]
    if [:dealer_busted, :player_wins].include? session[:state]
      session[:player_money] += (2*session[:player_bet])
    elsif [:result_tie].include? session[:state]
      session[:player_money] += session[:player_bet]
    end

    session[:player_bet] = nil
  end

  erb :'game/display'
end