# figure out where we are being loaded from
ENV['RACK_ENV'] = 'test'
ENV['PUPPETFILE_GIT_URL'] = 'https://example.com/repo.git'
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

# https://github.com/eliotsykes/rspec-rails-examples/blob/master/spec/spec_helper.rb
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    ResqueSpec.reset!
  end

  include Test::Methods

  def app
    Reaktor::Server
  end
end
