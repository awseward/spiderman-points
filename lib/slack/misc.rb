# frozen_string_literal: true

module Slack
  module Misc
    def with_graceful_slack_failure
      yield
    rescue Slack::Web::Api::Errors::SlackError => e
      halt \
        200,
        { 'Content-Type' => 'text/plain' },
        <<~MSG
          It looks like we may have some trouble reaching Slack…

          Requests to Slack have returned the following error(s): `#{e&.to_s}`.

          You may want to consider checking https://status.slack.com.
        MSG
    end
  end
end
