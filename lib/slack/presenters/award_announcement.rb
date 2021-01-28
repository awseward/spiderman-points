module Slack
  module Presenters

    module Formatting
      def render_id(id) = "<@#{id}>"

      def render_quote(text) = text.each_line.map { |line| "> #{line.strip}" }.join("\n")

      def one_or_many(quantity, one_val)
        # TODO: Maybe a slightly better error?
        raise ArgumentError, "Error: `one_or_many` requires `quantity` >= 1" if quantity < 1

        if quantity == 1
          one_val
        else
          yield quantity
        end
      end

      def with_reason(point, message)
        reason = point.reason
        if reason.present?
          yield [reason]
        else
          message
        end
      end
    end

    module AwardAnnouncement
      class Example
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          :FIXME
        end
      end

      class Lorem
        extend Slack::Presenters::Formatting

        def self.render(point, total_points) =
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et #{render_id point.to_id} habet #{total_points} Spidermanus Pointiae"
      end

      class Classic
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          message = "#{render_id point.from_id} has awarded ONE (1) Spiderman Point to #{render_id point.to_id}!"
          message = with_reason(point, message) do
            <<~MSG
             #{message} Why?
             #{render_quote point.reason}
            MSG
          end

          points_token = one_or_many(
            total_points,
            'your first Spiderman Point'
          ) { |many| "#{many} Spiderman Points" }

          <<~MSG
            #{message} 🎉 Congratulations, #{render_id point.to_id}, you now have #{points_token}! We're all so proud of you, keep it up!!!
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

          with_reason(point, message) do
            <<~MSG
              #{message} Oh, btw #{render_id point.from_id} also wanted me to tell you this:
              #{render_quote point.reason}
            MSG
          end
        end
      end

      class HaveYouEver
        extend Slack::Presenters::Formatting

        def self.render(point, total_points)
          message = <<~MSG
            Has Anyone Really Been Far Even as Decided to Use Even Go Want to do Spideman Points? #{render_id point.to_id} sure has!!!
          MSG

          with_reason(point, message) do
            <<~MSG
              #{message} When asked for comment, #{render_id point.from_id} said this:
              #{render_quote point.reason}
            MSG
          end
        end
      end

      class AndSoCanYou
        extend Slack::Presenters::Formatting

        def self.render(point, total_points) =
          "#{render_id point.to_id} is Spiderman Point and so can you! #{total_points} sure is nothing to sneeze at..."
      end

      KLASSES = [
        AndSoCanYou,
        Classic,
        HaveYouEver,
        Hey,
        Lorem,
        Mfw,
        PizzaTime,
      ]

      def self.random(...) = KLASSES.sample.render(...)
    end
  end
end
