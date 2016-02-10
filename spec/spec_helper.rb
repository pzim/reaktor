# figure out where we are being loaded from
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

require 'rspec'
require 'json'
require 'yaml'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

PROJECT_ROOT = File.expand_path('../../lib/reaktor', __FILE__)
SPEC_ROOT    = File.expand_path('../lib/reaktor',    __FILE__)

$LOAD_PATH.unshift(PROJECT_ROOT).unshift(SPEC_ROOT)

module Test
  module Methods
    def read_fixture(name)
      # f = File.open("spec/unit/fixtures/created.json", "r")
      # f.each_line do |line|
      #  puts line
      # end
      # f.close
      File.read(File.join(File.expand_path('..', __FILE__), 'unit', 'fixtures', name))
    end
  end
end

# FIXME: much of this configuration is duplicated in the :environment task in
# the Rakefile
RSpec.configure do |_config|
  ENV['RACK_ENV'] = 'test'
  include Test::Methods
end
