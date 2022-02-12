# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  module DevelopmentRoutes
    def self.registered(app)
      return unless app.development?

      app.get('/dev') { erb :'dev/index' }

      app.get '/dev/slash_command' do
        @slash_command = '/spiderman-points'
        @response_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/dev/slash_command/ws_echo"
        @team_id = 'T12345'
        @user_id = 'U12345'

        erb :'dev/slash_command'
      end

      app.post '/dev/slash_command/ws_echo' do
        msg = {
          __message_type__: 'SLACK_RESPONSE',
          body: JSON.parse(request.body.read),
        }
        request.env.fetch('ws_clients', []).each { _1.send msg.to_json }
        204
      end
    end
  end
end
