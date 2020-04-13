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

  def self.recent(params, points)
    if points.empty?
      return <<~MSG
        Didn't find any Spiderman Points...

        #{usage_suggestion params}
      MSG
    end

    rendered_points = points.
      map do |point|
        [
          '*',
          "#{render_id point.to_id} received ONE (1) Spiderman Point",
          point.reason.present? ? "`#{point.reason}`" : nil,
          "from #{render_id point.from_id}",
        ].compact.join(' ')
      end.
      join "\n"

    <<~MSG
      Here the #{points.count} most recent Spiderman Points:

      #{rendered_points}

      Now, go on! Those Spiderman Points aren't going to give themselves out!
    MSG
  end

  def self.scoreboard(params, scores)
    if scores.empty?
      return <<~MSG
        Didn't find any Spiderman Points...

        #{usage_suggestion params}
      MSG
    end

    rendered_scores = scores.map.with_index do |score, index|
      "#{index + 1}. #{render_id score[:user_id]} has given out `#{score[:count]}` Spiderman Points"
    end.join "\n"

    <<~MSG
    👋 Here's what you all have been up to:

    #{rendered_scores}


    Pretty good! But can we do better?
    MSG
  end

  def self.auth_test_result(result)
    "```#{result}```"
  end

  def self.self_awarded_point_admonishment(params)
    <<~MSG
      Unfortunately, you can't award Spiderman Points to yourself. Nice try, though!

      #{SlackPresenters.usage_suggestion params}
    MSG
  end
end
