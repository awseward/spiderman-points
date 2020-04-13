# frozen_string_literal: true
module Awardable
  class SelfAwardedError < StandardError; end

  def from_slash_command(params)
    new(**ingest_params(params))
  end

  def ingest_params(params)
    match  = params['text'].match SlashCommand::TextMatchers::Award::PATTERN
    reason = begin
               raw = match[3]&.strip
               raw == '' ? nil : raw
             end
    participant_ids = { from_id: params['user_id'], to_id: match[1] }
    {
      team_id: params['team_id'],
      reason:  reason
    }.merge ingest_participant_ids( **participant_ids )
  end

  def ingest_participant_ids(**keywords)
    keywords
  end
end
