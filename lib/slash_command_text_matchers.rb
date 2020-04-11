# frozen_string_literal: true

module SlashCommand
  module TextMatchers
    class Award
      PATTERN = /<@([A-Z][A-Z0-9]+)(\|[^>]*)?>(.*)/

      SpidermanPoint = Struct.new(
        :from,
        :to,
        :reason,
        keyword_init: true
      )

      def self.===(text)
        !!( text =~ PATTERN )
      end

      def self.parse(from:, text:)
        match = text.match PATTERN

        SpidermanPoint.new(
          from: from,
          to: match[1],
          reason: match[3]
        )
      end
    end
  end
end
