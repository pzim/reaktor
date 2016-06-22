source 'https://rubygems.org'

gem 'rake', '10.3.2'
gem 'sinatra', '1.4.5'
gem 'sinatra-contrib', '1.4.2'
gem 'json', '~> 1.8'
gem 'redis', '3.0.7'
gem 'redis-objects', '0.9.1'
gem 'resque', '1.25.2'
gem 'resque-retry', '1.1.4'
gem 'thin', '1.6.2'
gem 'god', '0.13.4'

# Pin versions for old ruby
if RUBY_VERSION.to_f < 2.0
  gem 'net-ssh', '2.9.1'
end

if RUBY_VERSION.to_f >= 2.2
  gem 'guard-rake', '1.0.0'
end

## gems for hipchat-api
gem 'hipchat-api', '1.0.6'
gem 'capistrano', '2.15.5'

group :test do
  gem 'rspec', '3.0.0'
  gem 'rack-test', '0.6.2'
  gem 'jsonlint'
  gem 'codeclimate-test-reporter', require: false
  gem 'coveralls', require: false
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
# vim:ft=ruby
