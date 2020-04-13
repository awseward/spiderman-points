# frozen_string_literal: true

class Point < ActiveRecord::Base
  extend Awardable

  def self.from_slash_command(params)
    hash = ingest_params(params)
    raise Awardable::SelfAwardedError if hash[:from_id] == hash[:to_id]
    new(**hash)
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
