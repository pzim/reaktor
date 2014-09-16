$LOAD_PATH.unshift("#{File.expand_path('..', __FILE__)}/lib/reaktor")
#$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'resque/tasks'
require 'envconfig'
require 'event_jobs'

ENV['RACK_ENV'] ||= 'production'
desc "Start the rack server`"
task :start do 
  Rake::Task["init_environment"].invoke
  exec "thin -C reaktor-cfg.yml -R config.ru start"
end

desc "Stop the rack server"
task :stop do
  exec "thin stop -C reaktor-cfg.yml"
end

desc "Start the resque workers and god watchers"
task :start_workers do
  exec "god -c god/resque_workers.god"
end

desc "Stop the resque workers and god watchers"
task :stop_workers do
  exec "god terminate god/resque_workers.god"
end

desc "initialize the environment configuration"
task :init_environment do
  Reaktor::Envconfig.init_environment(ENV['RACK_ENV'])
end

desc "Get the resque config settings for env"
task :load_config do
  config = Reaktor::Envconfig.dbconfig(ENV['RACK_ENV'])
  server = config[ENV['RACK_ENV']]
  puts "server = #{server}"
end
