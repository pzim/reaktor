require 'spec_helper'
require 'r10k/puppetfile'
require 'fileutils'

describe Reaktor::R10K::Puppetfile do
  let(:logger)  { double('logger').as_null_object }
  let(:branch) { ('reaktor_test1') }
  let(:branch2) { ('reaktor_test2') }
  let(:mod) { ('testmod1') }
  let(:mod2) { ('testmod2') }
  let(:now) { Time.now.strftime('%Y%m%d%H%M%S%L') }
  #let(:puppetfile_orig) { File.new(read_fixture("Puppetfile")) }
  let(:puppetfile_orig) { File.new("spec/unit/fixtures/Puppetfile") }
  let(:git_work_dir) { FileUtils.mkdir_p('/var/tmp/puppetfile_test') }

  subject { described_class.new(branch, mod, logger) }

  it 'should update mod testmod1 ref to be branch name' do
    subject.git_work_dir = git_work_dir[0]
    FileUtils.cp("spec/unit/fixtures/Puppetfile", "#{git_work_dir[0]}/Puppetfile")
    contents = subject.update_module_ref(mod, branch)
    expect(contents).to include(branch)
  end

  it 'should update mod testmod2 ref to be branch2 name' do
    subject.git_work_dir = git_work_dir[0]
    FileUtils.cp("spec/unit/fixtures/Puppetfile", "#{git_work_dir[0]}/Puppetfile")
    contents = subject.update_module_ref(mod2, branch2)
    expect(contents).to include(branch2)
  end
##
#  it 'created should be true' do
#    created = subject.created
#    expect(created).to eql (true)
#  end
#
#  it 'deleted should be false' do
#    deleted = subject.deleted
#    expect(deleted).to eql (false)
#  end
#
#  it 'repo name should be webhook_test_two' do
#    repo_name = subject.repo_name
#    expect(repo_name).to eql ('webhook_test_two')
#  end
end
