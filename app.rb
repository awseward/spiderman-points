require 'rest-client'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'slack'

Dir["#{Dir.pwd}/lib/**/*.rb"].each { |file| require file }
Dir["#{Dir.pwd}/models/**/*.rb"].each { |file| require file }

class App < Sinatra::Base
  include Slack::RequestValidation
  register Sinatra::DevelopmentRoutes if development?

  # Unnecessary, but handy when I need to turn it off locally
  set :show_exceptions, development?

  def custom_error(error_code)
    @background_image_url = 'https://media.giphy.com/media/K96dWImE4eHVS/giphy.gif'
    erb :"errors/#{error_code}"
  end

  def development?
    self.class.development?
  end

  def todo
    @background_image_url = 'https://i.imgur.com/z8rTFgG.gif'
    status 501
    erb :'errors/under_construction'
  end

  error(404) { custom_error 404 }
  error(500) { custom_error 500 }

  get('/') { erb :index }

  get('/tos')     { todo }
  get('/privacy') { todo }
  get('/support') { todo }
  get('/install_complete') { erb :install_complete }

  before '/slack/*' do
    validate_slack_token unless development?
    @slack_client = unless development?
      token = OauthCredential.team_access_code params['team_id']
      client = Slack::Web::Client.new(token: token)
      client.auth_test

      client
    end
  end

  before '/slack/slash_command' do
    # Log the basics
    puts "[#{params['team_id']}.#{params['user_id']}]: #{params['command']} #{params['text']}"

    # Say hi if we need to
    @user = User.find_by(
      team_id: params['team_id'],
      user_id: params['user_id']
    )
    unless @user.present?
      whisper(
        url: params['response_url'],
        text: Slack::Presenters.first_time_greeting(params)
      )
      @user = persist_user(params)
    end
  end

  post '/slack/slash_command' do
    case params['text']
    when Slack::SlashCommand::TextMatchers::Empty
      Slack::Presenters.response_for_empty_command params

    when Slack::SlashCommand::TextMatchers::Award
      point = Point.from_slash_command params
      point.save!
      speak(
        url: params['response_url'],
        text: Slack::Presenters.award_announcement(point)
      )
      # NOTE: No response directly back to user required. The `nil` returned
      # here accomplishes that.
      nil

    when Slack::SlashCommand::TextMatchers::Recent
      points = Point.recent(team_id: params['team_id'])
      Slack::Presenters.recent(params, points)

    when Slack::SlashCommand::TextMatchers::Scoreboard
      scores = Point.scores(team_id: params['team_id'])
      Slack::Presenters.scoreboard(params, scores)

    when Slack::SlashCommand::TextMatchers::Help
      base_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      Slack::Presenters.help(params, base_url: base_url)

    when 'slack_auth_test'
      Slack::Presenters.auth_test_result @slack_client.auth_test

    else
      Slack::Presenters.response_for_invalid_command params

    end
  rescue Awardable::SelfAwardedError
    SelfAwardedPoint.from_slash_command(params).save!
    Slack::Presenters.self_awarded_point_admonishment params
  end

  get '/oauth/slack' do
    # TODO: Validation

    response_body = RestClient.post('https://slack.com/api/oauth.v2.access', {
      code: params['code'],
      client_id: ENV['SLACK_OAUTH_CLIENT_ID'],
      client_secret: ENV['SLACK_OAUTH_CLIENT_SECRET']
    }).body

    OauthCredential.upsert_from_slack_response JSON.parse(response_body)

    redirect to('/install_complete')
  end

  get('/*') { 404 }

  # start the server if ruby file executed directly
  run! if app_file == $0

  private

  def whisper(**args)
    post_response( **args.merge(response_type: 'ephemeral') )
  end

  def speak(**args)
    post_response( **args.merge(response_type: 'in_channel') )
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
