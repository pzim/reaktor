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

  describe '.setup' do
    let :options do
      {
        module_name: 'foo-bar',
        branch_name: 'feature'
      }
    end
    subject { described_class.new(options) }
    it 'setups the action' do
      git_work_dir = instance_double('Reaktor::Git::WorkDir')
      allow(Reaktor::Git::WorkDir).to receive(:new).and_return(git_work_dir)
      allow(git_work_dir).to receive(:clone)
      expect(git_work_dir).to receive(:clone)
      expect(git_work_dir).to receive(:checkout).with('feature')
      subject.setup
    end
  end

  describe '.cleanup' do
    let :options do
      {
        module_name: 'foo-bar',
        branch_name: 'feature'
      }
    end
    subject { described_class.new(options) }
    it 'setups the action' do
      git_work_dir = instance_double('Reaktor::Git::WorkDir')
      allow(Reaktor::Git::WorkDir).to receive(:new).and_return(git_work_dir)
      allow(git_work_dir).to receive(:destroy_workdir)
      expect(git_work_dir).to receive(:destroy_workdir)
      subject.cleanup
    end
  end

  describe '.update_puppet_file' do
    context 'given a module of "foo-bar" and a branch of "feature"' do
      let :options do
        {
          module_name: 'foo-bar',
          branch_name: 'feature'
        }
      end
      subject { described_class.new(options) }
      it 'calls somethinh with the branchname' do
        puppetfile = instance_double('Reaktor::R10K::Puppetfile')
        allow(Reaktor::R10K::Puppetfile).to receive(:new).and_return(puppetfile)
        allow(puppetfile).to receive(:loadFile).and_return(read_fixture('Puppetfile'))
        now = Time.now.strftime('%Y%m%d%H%M%S%L')
        allow(puppetfile).to receive(:git_work_dir).and_return(File.expand_path("/var/tmp/puppetfile_repo_#{now}"))
        allow(puppetfile).to receive(:git_url).and_return('https://example.com/git/foo-bar.git')
        allow(puppetfile).to receive(:update_module_ref).with('foo-bar', 'feature').and_return('puppetfile contents')
        allow(puppetfile).to receive(:git_update_ref_msg).and_return('this is the commit message')
        allow(puppetfile).to receive(:write_new_puppetfile).and_return(true)
        allow(puppetfile).to receive(:get_module_name).and_return('foo-bar')

        git_work_dir = instance_double('Reaktor::Git::WorkDir')
        allow(Reaktor::Git::WorkDir).to receive(:new).and_return(git_work_dir)
        allow(git_work_dir).to receive(:push).with('feature', 'this is the commit message').and_return(true)

        expect(puppetfile).to receive(:write_new_puppetfile).with('puppetfile contents')

        # TODO: ???
        # expect(deploy).to receive(:deploy).with('feature')
        subject.update_puppet_file
      end
    end
  end
end
