module SlackPresenters
  def self.award_announcement(point)
    announcement = "#{render_id point.from_id} has awarded ONE (1) Spiderman Point to #{render_id point.to_id}!"
    announcement = if point.reason.present?
                    <<~MSG
                      #{announcement} Why?

                      > #{point.reason}
                    MSG
                  else
                    announcement
                  end
    # FIXME: It's a pretty terrible idea to put a query like this in this
    # method, but for now it _really_ doesn't matter. Just please revisit this
    # sometime in the future.
    total_points = Point.where(team_id: point.team_id, to_id: point.to_id).count
    points_token = if total_points == 1
                     "your first Spiderman Point"
                   elsif total_points > 1
                     "#{total_points} Spiderman Points"
                   else
                     raise "ERR ENOSPIDERMANPOINTS: Replace this with a better error maybe"
                   end

    <<~MSG
      #{announcement}

      🎉 Congratulations, #{render_id point.to_id}, you now have #{points_token}! We're all so proud of you, keep it up!!!
    MSG
  end

  def self.response_for_invalid_command(params)
    <<~MSG
      🤔 Sorry, I couldn't tell what you meant when you sent this:
      ```
      #{params['command']} #{params['text']}
      ```

      #{usage_suggestion params}
    MSG
  end

  def self.first_time_greeting(params)
    "Hi there, #{render_id params['user_id']}! It's a pleasure to meet you!"
  end

  def self.response_for_empty_command(params)
    "Hi there! Not sure what to do? #{usage_suggestion params}"
  end

  def self.usage_suggestion(params)
    "Try awarding a Spiderman Point to someone via `#{params['command']} @<their_username>` !"
  end

  def self.render_id(id)
    "<@#{id}>"
  end
end
