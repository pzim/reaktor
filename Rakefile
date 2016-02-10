$LOAD_PATH.unshift("#{File.expand_path('..', __FILE__)}/lib/reaktor")
# $LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
# ---- start common Rakefile  -----
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

desc 'Display the list of available rake tasks'
task :help do
  system('rake -T')
end

task default: [:help]

require 'jsonlint/rake_task'
JsonLint::RakeTask.new do |t|
  t.paths = %w(
    spec/**/*.json
  )
end

desc 'Check syntax of ruby files'
task :syntax do
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
end

desc 'Run full test suite'
task test: [
  :jsonlint,
  :rubocop,
  :spec
]

# ---- end common Rakefile  -----

require 'resque/tasks'
require 'envconfig'
require 'event_jobs'

ENV['RACK_ENV'] ||= 'production'
desc 'Start the rack server`'
task :start do
  Rake::Task['init_environment'].invoke
  exec 'thin -C reaktor-cfg.yml -R config.ru start'
end

desc 'Stop the rack server'
task :stop do
  exec 'thin stop -C reaktor-cfg.yml'
end

desc 'Start the resque workers and god watchers'
task :start_workers do
  exec 'god -c god/resque_workers.god'
end

desc 'Stop the resque workers and god watchers'
task :stop_workers do
  exec 'god terminate god/resque_workers.god'
end

desc 'initialize the environment configuration'
task :init_environment do
  Reaktor::Envconfig.init_environment(ENV['RACK_ENV'])
end

desc 'Get the resque config settings for env'
task :load_config do
  config = Reaktor::Envconfig.dbconfig(ENV['RACK_ENV'])
  server = config[ENV['RACK_ENV']]
  puts "server = #{server}"
end
