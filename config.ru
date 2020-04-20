require 'pry' if ENV['RACK_ENV'] == 'development'

require './app'
$stdout.sync = true

require './middlewares/ws_backend'
use WsDemo::WsBackend

run App
