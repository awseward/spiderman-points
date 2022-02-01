# frozen_string_literal: true

require 'rest-client'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'slack'

[
  'lib/**/*.rb',
  'models/**/*.rb'
].flat_map { Dir[Pathname.new(Dir.pwd) / _1] }.each { require _1 }

class App < Sinatra::Base
  include Slack::RequestValidation
  include Slack::Misc
  register Sinatra::DevelopmentRoutes if development?

  # Unnecessary, but handy when I need to turn it off locally
  set :show_exceptions, development?

  def development? = self.class.development?

  def base_url
    scheme = request.env.fetch 'rack.url_scheme'
    host = request.env.fetch 'HTTP_HOST'

    "#{scheme}://#{host}"
  end

  get('/health') do
    content_type :json
    {}.to_json
  end

  before '/slack/*' do
    with_graceful_slack_failure do
      validate_slack_token unless development?
      @slack_client = unless development?
        token = OauthCredential.team_access_code params['team_id']
        client = Slack::Web::Client.new(token: token)
        client.auth_test

        client
      end
    end
  end

  before '/slack/slash_command' do
    with_graceful_slack_failure do
      # Log the basics
      puts "[#{params['team_id']}.#{params['user_id']}]: #{params['command']} #{params['text']}"

      @user = User.find_by(
        team_id: params['team_id'],
        user_id: params['user_id']
      )
      @responder = Slack::Responder.for_params params

      # Say hi if we need to
      unless @user.present?
        @responder.ephemeral Slack::Presenters.first_time_greeting(params)
        @user = User.new(
          team_id:   params['team_id'],
          user_id:   params['user_id'],
          opted_out: false # 🤔
        ).save!
      end
    end
  end

  post '/slack/slash_command' do
    with_graceful_slack_failure do
      case params['text']
      when Slack::SlashCommand::TextMatchers::Empty
        Slack::Presenters.response_for_empty_command params

      when Slack::SlashCommand::TextMatchers::Award
        point = Point.from_slash_command params
        recipient = User.find_by(
          team_id: params['team_id'],
          user_id: point.to_id
        )

        if recipient.present? && recipient.opted_out
          @responder.ephemeral(
            Slack::Presenters.recipient_has_opted_out(recipient.id)
          )
        else
          point.save!
          total_points = Point.where(team_id: point.team_id, to_id: point.to_id).count
          @responder.in_channel Slack::Presenters.award_announcement(point, total_points)
        end

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
        Slack::Presenters.help(params, base_url: Www.base_url || base_url)

      when Slack::SlashCommand::TextMatchers::Opt::Out
        @user.update!(opted_out: true)
        Slack::Presenters.opt_out_successful params

      when Slack::SlashCommand::TextMatchers::Opt::In
        @user.update!(opted_out: false)
        Slack::Presenters.opt_in_successful

      when Slack::SlashCommand::TextMatchers::SlackAuthTest
        Slack::Presenters.auth_test_result begin
          @slack_client.auth_test
        rescue StandardError => e
          e.message
        end

      when Slack::SlashCommand::TextMatchers::SlackErrorTest
        raise Slack::Web::Api::Errors::SlackError, 'This is only a test'

      else
        Slack::Presenters.response_for_invalid_command params

      end
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

    redirect to("#{Www.base_url}/installed.html")
  end

  get('/*') { 404 }

  # start the server if ruby file executed directly
  run! if app_file == $0
end
