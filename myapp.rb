require 'sinatra'

get '/' do 
    'Hello world'
end

get '/hello/:name' do 
  "Hello #{params[:name]}"
end

class Stream
  def each
    100.times { |i| yield "#{i}\n" }
  end
end

get('/stream') { Stream.new }