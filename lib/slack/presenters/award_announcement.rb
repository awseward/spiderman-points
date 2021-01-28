module Slack
  module Presenters

    module Formatting
      def render_id(id) = "<@#{id}>"

      def render_quote(reason) = reason.each_line.map { |line| "> #{line.strip}" }.join("\n")

      def one_or_many(quantity, one_val)
        # TODO: Maybe a slightly better error?
        raise ArgumentError, "Error: `one_or_many` requires `quantity` >= 1" if quantity < 1

        if quantity == 1
          one_val
        else
          yield quantity
        end
      end
    end

    module AwardAnnouncement
      class Example
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          'TODO'
        end
      end

      class Classic
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          announcement = "#{render_id point.from_id} has awarded ONE (1) Spiderman Point to #{render_id point.to_id}!"
          announcement = if point.reason.present?
            <<~MSG
             #{announcement} Why?

             #{render_quote point.reason}
            MSG
          else
            announcement
          end

          points_token = one_or_many(
            total_points,
            'your first Spiderman Point'
          ) { |many| "#{many} Spiderman Points" }

          <<~MSG
            #{announcement}

            🎉 Congratulations, #{render_id point.to_id}, you now have #{points_token}! We're all so proud of you, keep it up!!!
          MSG
        end
      end

      class PizzaTime
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          points_token = one_or_many(
            total_points,
            'your first Spiderman Point'
          ) { |many| "#{many} Spiderman Points" }

          "🍕 PIZZA TIME!!!! 🍕 One hot, fresh Spiderman Point coming up for #{render_id point.to_id}, courtesy of #{render_id point.from_id}! That makes #{points_token}! How does it feel?"
        end
      end

      class Mfw
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          r_to = render_id point.to_id
          "mfw #{render_id point.from_id} just gave #{r_to} a Spiderman Point... (btw #{r_to}, you have #{total_points} of them now)"
        end
      end

      class Hey
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          message = "Hey #{render_id point.to_id}, have a Spiderman Point! Don't spend it all in one place!"

          if point.reason.present?
            <<~MSG
              #{message} Oh, btw #{render_id point.from_id} also wanted me to tell you this:

              #{render_reason point.reason}
            MSG
          else
            message
          end
        end
      end

      KLASSES = [
        Classic,
        Hey,
        Mfw,
        PizzaTime,
      ]

      def self.random(...) = KLASSES.sample.render(...)
    end
  end
end
