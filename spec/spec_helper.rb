# figure out where we are being loaded from
ENV['RACK_ENV'] = 'test'
require 'simplecov'
require 'coveralls'
SimpleCov.start do
  add_group 'Tests', 'spec'
  add_group 'App', 'lib'
end
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

require 'rspec'
require 'json'
require 'yaml'
require 'rack/test'
require 'resque_spec'
require 'reaktor'
require 'reaktor/server'

module Test
  module Methods
    def read_fixture(name)
      File.read(File.join(File.expand_path('..', __FILE__), 'unit', 'fixtures', name))
    end
  end
end

# FIXME: much of this configuration is duplicated in the :environment task in
# the Rakefile
RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    ResqueSpec.reset!
  end

  include Test::Methods

  def app
    Reaktor::Server
  end
end
