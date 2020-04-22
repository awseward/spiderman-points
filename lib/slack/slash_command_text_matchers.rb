# frozen_string_literal: true

module Slack
  module SlashCommand
    module TextMatchers
      class Empty
        def self.===(text)
          text.nil? || text.strip == ''
        end
      end

      class Award
        PATTERN = /<@([A-Z][A-Z0-9]+)(\|[^>]*)?>(.*)/

        def self.===(text)
          !!( text =~ PATTERN )
        end
      end

      class Recent
        def self.===(text)
          TextMatchers.first_term(text) == 'recent'
        end
      end

      class Scoreboard
        def self.===(text)
          TextMatchers.first_term(text) == 'scoreboard'
        end
      end

      class Help
        def self.===(text)
          TextMatchers.first_term(text) == 'help'
        end
      end

      def self.first_term(text)
        text&.split(' ')&.first&.downcase
      end
    end
  end
end
