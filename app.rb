require 'pry'
require 'rest-client'
require 'sinatra/base'
require 'sinatra/activerecord'

Dir["#{Dir.pwd}/lib/**/*.rb"].each { |file| require file }
Dir["#{Dir.pwd}/models/**/*.rb"].each { |file| require file }

class App < Sinatra::Base
  include SlackRequestValidation

  not_found do
    status 404
    nil
  end

  before '/slack/*' do
    validate_slack_token unless ENV['RACK_ENV'] == 'development'
  end

  post '/slack/slash_command' do
    puts params
    user = User.find_by(
      team_id: params['team_id'],
      user_id: params['user_id']
    )

    unless user.present?
      whisper(
        url: params['response_url'],
        text: "Hi there, <@#{params['user_id']}>! Pleasure to meet you!"
      )
      persist_user(params)
    end

    text = params['text']

    case text
    when SlashCommand::TextMatchers::Empty
      "Try awarding a Spiderman Point to someone via `#{params['command']} @<their_username>` !"
    when SlashCommand::TextMatchers::Award
      point = Point.from_slash_command params
      point.save!
      speak url: params['response_url'], text: point.to_slack_announcement
    else
      <<~MSG
        🤔 Sorry, not really sure what to make of this...

        ```
        #{params['command']} #{text}
        ```
      MSG
    end
  end

  post '/dev/null' do
    status 204
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

  private

  def whisper(**args)
    post_response args.merge(response_type: 'ephemeral')
  end

  def speak(**args)
    post_response args.merge(response_type: 'in_channel')
  end

  def post_response(url:, text:, response_type:)
    RestClient.post(
      url,
      { text: text, response_type: response_type }.to_json,
      { content_type: 'application/json' }
    )
  end

  def persist_user(params)
     User.new(
       team_id: params['team_id'],
       user_id: params['user_id']
     ).save!
  end
end
