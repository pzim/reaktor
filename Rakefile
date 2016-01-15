$LOAD_PATH.unshift("#{File.expand_path('..', __FILE__)}/lib/reaktor")
#$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'resque/tasks'
require 'envconfig'
require 'event_jobs'

begin
  require 'jsonlint/rake_task'
  JsonLint::RakeTask.new do |t|
    t.paths = %w(
        spec/**/*.json
      )
  end
rescue LoadError
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--format documentation'
  end
rescue LoadError
end

task :default => [:help]

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


desc "Populate CONTRIBUTORS file"
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

desc "Check syntax of ruby files"
task :syntax do
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  #Dir['**/*.json'].each do |json_file|
  #  JSON.parse(File.open("#{json_file}").read)
  #end
end


desc "Run full test suite"
task :test => [
  :jsonlint,
  :syntax,
  :spec,
]

desc "Display the list of available rake tasks"
task :help do
    system("rake -T")
end

