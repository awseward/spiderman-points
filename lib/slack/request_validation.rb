# frozen_string_literal: true

require 'active_support/security_utils'

# Adapted from https://web.archive.org/web/20200411182503/https://chatbotslife.com/creating-and-configuring-a-slack-app-62d669894015?gi=d118fb8c556b
module Slack
  module RequestValidation
    def validate_slack_token
      timestamp       = get_header('X-Slack-Request-Timestamp').to_i
      slack_signature = get_header('X-Slack-Signature')

      unless timestamp.present? && slack_signature.present?
        puts "missing timestamp or signature"
        halt 401
      end

      if slack_request_too_old? timestamp
        puts "request too old"
        halt 401
      end

      body = request.body.read
      sig_basestring = "v0:#{timestamp}:#{body}"
      signature = "v0=#{OpenSSL::HMAC.hexdigest("SHA256", ENV['SLACK_SIGNING_SECRET'], sig_basestring)}"
      signatures_match = ActiveSupport::SecurityUtils::secure_compare(signature, slack_signature)

      unless signatures_match
        puts "signature mismatch"
        halt 401
      end
    end

    # X-Foo-Bar => HTTP_X_FOO_BAR
    def get_header(key) = request.env["HTTP_#{key.upcase.gsub('-', '_')}"]

    # if over 5 minutes it can be a replay attack
    def slack_request_too_old?(timestamp) = (Time.now.to_i - timestamp).abs > (60 * 5)
  end
end
