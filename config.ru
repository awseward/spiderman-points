require 'pry' if ENV['RACK_ENV'] == 'development'

require './app'
$stdout.sync = true

run App
