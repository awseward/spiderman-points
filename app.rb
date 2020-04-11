require 'sinatra/base'
require 'pry'

class App < Sinatra::Base
  post '/slack/slash_command' do
    @req_data = JSON.parse request.body.read
    puts @req_data

    'Hello'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
