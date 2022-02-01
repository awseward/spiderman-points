# frozen_string_literal: true

require 'faye/websocket'

# https://github.com/jeremyevans/roda/issues/44#issuecomment-138140240
class Rack::Lint::HijackWrapper
  def to_int
    @io.to_i
  end
end

module WsDemo
  class WsBackend
    KEEPALIVE_TIME = 1 # in seconds

    def initialize(app)
      @app = app
      @clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on :open do |_event|
          p [:open, ws.object_id]
          @clients << ws
        end

        ws.on(:message) { p [:message, _1.data] }

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete ws
          ws = nil
        end

        ws.rack_response
      else
        env['ws_clients'] = @clients
        @app.call env
      end
    end
  end
end
