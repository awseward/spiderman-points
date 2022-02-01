# frozen_string_literal: true

module Slack
  module SlashCommand
    module TextMatchers
      class Empty
        def self.===(text) = text.nil? || text.strip == ''
      end

      class Award
        PATTERN = /<@([A-Z][A-Z0-9]+)(\|[^>]*)?>(.*)/m

        def self.===(text) = !!( text =~ PATTERN )
      end

      class Recent
        def self.===(text) = TextMatchers.first_term(text) == 'recent'
      end

      class Scoreboard
        def self.===(text) = TextMatchers.first_term(text) == 'scoreboard'
      end

      class Help
        def self.===(text) = TextMatchers.first_term(text) == 'help'
      end

      module Opt
        class In
          def self.===(text) = TextMatchers.first_two_terms(text) == %w[opt in]
        end

        class Out
          def self.===(text) = TextMatchers.first_two_terms(text) == %w[opt out]
        end
      end

      module SlackAuthTest
        def self.===(text) = TextMatchers.first_term(text) == 'slack_auth_test'
      end

      module SlackErrorTest
        def self.===(text) = TextMatchers.first_term(text) == 'slack_error_test'
      end

      def self.first_term(text) = text&.split(' ')&.first&.downcase

      def self.first_two_terms(text)
        fst, snd = text&.split(' ')
        [fst, snd].compact.map { |str| str.strip.downcase }
      end
    end
  end
end
