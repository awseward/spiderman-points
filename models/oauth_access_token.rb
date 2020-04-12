# frozen_string_literal: true

class OauthCredential < ActiveRecord::Base
  def self.from_slack_response(response)
    new(
      app_id:         response['app_id'],
      team_id:        response.dig('team', 'id'),
      access_token:   response['access_token'],
      scope:          response['scope'],
      bot_user_id:    response['bot_user_id'],
      authed_user_id: response.dig('authed_user', 'id')
    )
  end
end
