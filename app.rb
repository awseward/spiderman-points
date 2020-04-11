require 'sinatra/base'
require 'pry'

class App < Sinatra::Base
  post '/slack/slash_command' do
    puts params

    'Hello! This will work soon, I promise.'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
