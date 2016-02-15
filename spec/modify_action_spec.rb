require 'spec_helper'
require 'reaktor/gitaction/modify_action'

describe Reaktor::GitAction::ModifyAction do
  context 'with logger subject' do
    let :options do
      {
        module_name: 'foo-bar',
        branch_name: 'feature',
        logger: Logger.new(STDOUT, Logger::INFO)
      }
    end
    subject { described_class.new(options) }
    it 'it should have initialized' do
      is_expected.to have_attributes(
        module_name: options[:module_name],
        branch_name: options[:branch_name],
        logger: options[:logger]
      )
    end
  end
  context 'without logger subject' do
    let :options do
      {
        module_name: 'foo-bar',
        branch_name: 'feature',
        logger: nil
      }
    end
    subject { described_class.new(options) }
    it 'it should have initialized' do
      is_expected.to have_attributes(
        module_name: options[:module_name],
        branch_name: options[:branch_name],
        logger: be_a(Logger)
      )
    end
  end
end
