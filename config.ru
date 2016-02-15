ENV['RACK_ENV'] ||= 'production'

rack_root = ENV['RACK_ROOT'] || './'
reaktor_log = ENV['REAKTOR_LOG'] || "#{rack_root}/log/reaktor.log"

require 'sinatra'
require 'resque/server'
require 'logger'
require 'reaktor/server'

LOGGER = Logger.new(reaktor_log.to_s)

run Rack::URLMap.new \
  '/'         => Reaktor::Server.new,
  '/resque'   => Resque::Server.new
