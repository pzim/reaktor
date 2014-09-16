# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
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
#require 'rack/test'
require 'json'
require 'yaml'

PROJECT_ROOT = File.expand_path("../../lib/reaktor", __FILE__)
SPEC_ROOT    = File.expand_path("../lib/reaktor",    __FILE__)

$LOAD_PATH.unshift(PROJECT_ROOT).unshift(SPEC_ROOT)

module Test
  module Methods
    def read_fixture(name)
      #f = File.open("spec/unit/fixtures/created.json", "r")
      #f.each_line do |line|
      #  puts line
      #end
      #f.close
      File.read(File.join(File.expand_path("..", __FILE__), "unit", "fixtures", name))
    end
  end
end

#require 'shared-contexts'

# FIXME much of this configuration is duplicated in the :environment task in
# the Rakefile
RSpec.configure do |config|
  ENV['RACK_ENV'] = 'test'
  include Test::Methods

#  config.mock_with :rspec

  #config.before :all do
  #  Reaktor::Envconfig.init_environment(ENV['RACK_ENV'])
  #end
end

#RSpec::Matchers.define :have_status do |expected_status|
#  match do |actual|
#    actual.status == expected_status
#  end
#  description do
#    "have a #{expected_status} status"
# end
#  failure_message_for_should do |actual|
#    <<-EOM
#expected the response to have a #{expected_status} status but got a #{actual.status}.
#Errors:
#{actual.errors}
#   EOM
#  end
#end
