require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :index
end
  
get '/player' do
  erb :'player/info'
end

