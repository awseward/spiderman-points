# frozen_string_literal: true

require 'rest-client'

module Slack
  class Responder
    def self.for_params(params)
      new(url: params['response_url'])
    end

    def initialize(url:)
      @url = url
    end

    def in_channel(text)
      post text, response_type: :in_channel
    end

    def ephemeral(text)
      post text, response_type: :ephemeral
    end

    private

    attr_reader :url

    def post(text, response_type:)
      RestClient.post(
        url,
        { text: text, response_type: response_type }.to_json,
        { content_type: 'application/json' }
      )
    end
  end
end
