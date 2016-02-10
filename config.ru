$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib/reaktor')

ENV['RACK_ENV'] ||= 'production'

rack_root = ENV['RACK_ROOT'] || '/data/apps/sinatra/reaktor'
reaktor_log = ENV['REAKTOR_LOG'] || "#{rack_root}/reaktor.log"

require 'sinatra'
require 'resque/server'
require 'logger'
require 'r10k_app'

LOGGER = Logger.new(reaktor_log.to_s)

run Rack::URLMap.new \
  '/'         => Reaktor::R10KApp.new,
  '/resque'   => Resque::Server.new
