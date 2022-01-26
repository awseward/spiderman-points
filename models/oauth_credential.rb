# frozen_string_literal: true

class OauthCredential < ActiveRecord::Base
  def self.upsert_from_slack_response(response)
    unnested_response = unnest_slack_response response
    existing_credential = find_by( **unnested_response.slice(:app_id, :team_id) )

    if existing_credential.present?
      existing_credential.update!( **unnested_response )
    else
      credential = new_from_slack_response response
      credential.save!
    end
  end

  def self.new_from_slack_response(response)
    new( **unnest_slack_response(response) )
  end

  def self.unnest_slack_response(response)
    {
      app_id:         response['app_id'],
      team_id:        response.dig('team', 'id'),
      access_token:   response['access_token'],
      scope:          response['scope'],
      bot_user_id:    response['bot_user_id'],
      authed_user_id: response.dig('authed_user', 'id')
    }
  end

  def self.team_access_code(team_id)
    find_by(team_id: team_id).access_token
  end
end
