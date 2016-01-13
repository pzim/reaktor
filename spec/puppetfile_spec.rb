require 'spec_helper'
require 'r10k/puppetfile'
require 'fileutils'
require 'tmpdir'

describe Reaktor::R10K::Puppetfile do
  let(:logger)  { double('logger').as_null_object }
  let(:branch) { ('reaktor_test1') }
  let(:branch2) { ('reaktor_test2') }
  let(:mod) { ('testmod1') }
  let(:mod2) { ('testmod2') }
  let(:repo_name) { ('myproject-testmod2') }

  let(:now) { Time.now.strftime('%Y%m%d%H%M%S%L') }
  #let(:puppetfile_orig) { File.new(read_fixture("Puppetfile")) }
  let(:puppetfile_orig) { File.new("spec/unit/fixtures/Puppetfile") }
  let(:git_work_dir) { Dir.mktmpdir('rspec') }


  subject { described_class.new(branch, mod, logger) }

  it 'should update mod testmod1 ref to be branch name' do
    subject.git_work_dir = git_work_dir
    FileUtils.cp("spec/unit/fixtures/Puppetfile", "#{git_work_dir}/Puppetfile")
    contents = subject.update_module_ref(mod, branch)
    expect(contents).to include(branch)
    FileUtils.remove_entry_secure git_work_dir
  end

  it 'should update mod testmod2 ref to be branch2 name' do
    subject.git_work_dir = git_work_dir
    FileUtils.cp("spec/unit/fixtures/Puppetfile", "#{git_work_dir}/Puppetfile")
    contents = subject.update_module_ref(mod2, branch2)
    expect(contents).to include(branch2)
    FileUtils.remove_entry_secure git_work_dir
  end

  it 'should retrieve testmod2 as module name' do
    subject.git_work_dir = git_work_dir
    FileUtils.cp("spec/unit/fixtures/Puppetfile", "#{git_work_dir}/Puppetfile")
    contents = subject.get_module_name(repo_name)
    expect(contents).to eq(mod2)
    FileUtils.remove_entry_secure git_work_dir
  end

end
