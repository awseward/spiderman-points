# frozen_string_literal: true

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
  end
end
