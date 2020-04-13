# frozen_string_literal: true

class Point < ActiveRecord::Base
  class SelfAwardedError < StandardError; end

  def self.from_slash_command(params)
    match   = params['text'].match SlashCommand::TextMatchers::Award::PATTERN
    from_id = params['user_id']
    to_id   = match[1]
    raise SelfAwardedError if from_id == to_id
    reason  = begin
                raw = match[3]&.strip
                raw == '' ? nil : raw
              end
    new(
      team_id: params['team_id'],
      from_id: from_id,
      to_id:   to_id,
      reason:  reason
    )
  end

  def self.recent(count: 10, **where_params)
    where(**where_params).
      order('created_at DESC').
      limit(count).
      sort_by(&:created_at)
  end

  def self.scores(team_id:)
    where(team_id: team_id).
      group('from_id').
      count.
      sort_by { |user_id, score| -score  }.
      map { |user_id, count| { user_id: user_id, count: count } }
  end
end
