# frozen_string_literal: true

class SelfAwardedPoint < ActiveRecord::Base
  extend Awardable

  class InvalidSelfAwardedPointError < StandardError; end

  def self.ingest_participant_ids(from_id:, to_id:)
    raise MiscategorizedSelfAwardError if from_id != to_id

    { user_id: from_id }
  end
end
