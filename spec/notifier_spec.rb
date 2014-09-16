require 'spec_helper'
require 'notification/notifier'

# need to figure out how best to test this, given it's a singleton
# until then, it's basically commented out
describe Reaktor::Notification::Notifier do
  let(:logger)  { double('logger').as_null_object }
  let(:filename) { "spec/unit/fixtures/notifiers/notifiertest.rb" }

  before :each do
    @notifier = Reaktor::Notification::Notifier.instance
  end

  #subject { Reaktor::Notification::Notifier.new { include Singleton } }

  #it 'should return class name of Notifiertest' do
  #  classname = @notifier.getClassFromFile(filename)
  #  expect(classname).to eql ('Notifiertest') 
  #end
end
