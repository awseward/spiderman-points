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

  def to_slack_announcement
    announcement = "#{render_id from_id} has awarded ONE (1) Spiderman Point to #{render_id to_id}!"
    announcement = if reason.present?
                    <<~MSG
                      #{announcement} Why?

                      > #{reason}
                    MSG
                  else
                    announcement
                  end
    # FIXME: It's a pretty terrible idea to put a query like this in this
    # method, but for now it _really_ doesn't matter. Just please revisit this
    # sometime in the future.
    total_points = Point.where(team_id: team_id, to_id: to_id).count
    points_token = if total_points == 1
                     "your first Spiderman Point"
                   elsif total_points > 1
                     "#{total_points} Spiderman Points"
                   else
                     raise "ERR ENOSPIDERMANPOINTS: Replace this with a better error maybe"
                   end

    <<~MSG
      #{announcement}

      🎉 Congratulations, #{render_id to_id}, you now have #{points_token}! We're all so proud of you, keep it up!!!
    MSG
  end

  private

  def render_id(id)
    "<@#{id}>"
  end
end
