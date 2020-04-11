# frozen_string_literal: true

class Point < ActiveRecord::Base
  def self.from_slash_command(params)
    match  = params['text'].match SlashCommand::TextMatchers::Award::PATTERN
    to_id  = match[1]
    reason = begin
               raw = match[3]&.strip
               raw == '' ? nil : raw
             end

    new(
      team_id: params['team_id'],
      from_id: params['user_id'],
      to_id:   to_id,
      reason:  reason
    )
  end
end
