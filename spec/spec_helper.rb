# figure out where we are being loaded from
ENV['RACK_ENV'] = 'test'
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise 'foo'
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require 'spec_helper'

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end
require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_group 'Tests', 'spec'
  add_group 'App', 'lib'
end

require 'rspec'
require 'json'
require 'yaml'
require 'rack/test'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'resque_spec'
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

  config.before(:each) do
    ResqueSpec.reset!
  end

  include Test::Methods
end
