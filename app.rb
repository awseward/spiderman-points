require 'pry'
require 'rest-client'
require 'sinatra/base'
require 'sinatra/activerecord'

Dir["#{Dir.pwd}/lib/**/*.rb"].each { |file| require file }
Dir["#{Dir.pwd}/models/**/*.rb"].each { |file| require file }

class App < Sinatra::Base
  not_found do
    status 404
    nil
  end

  post '/slack/slash_command' do
    puts params
    user = User.find_by(
      team_id: params['team_id'],
      user_id: params['user_id']
    )

    greeting = if user.present?
                 "Welcome back, #{params['user_name']}!"
               else
                 persist_user(params)
                 "Hi there, #{params['user_name']}! Pleasure to meet you!"
               end

    post_response(url: params['response_url'], text: greeting)

    case
    when SlashCommand::TextMatchers::Award
      point = SlashCommand::TextMatchers::Award.parse(
        from: params['user_id'],
        text: params['text']
      )
      # NOTE: Rework this
      "<@#{point.from}> has awarded one (1) Spiderman point to <@#{point.to}>! (reason: `#{point.reason}`)"
    else
      '🤔 Sorry, not really sure what to make of that...'
    end
  end

  post '/dev/null' do
    status 204
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

  private

  def post_response(url:, text:)
    RestClient.post(url, { text: text }.to_json, { content_type: 'application/json' })
  end

  def persist_user(params)
     User.new(
       team_id: params['team_id'],
       team_domain: params['team_domain'],
       user_id: params['user_id'],
       user_name: params['user_name']
     ).save!
  end

end
