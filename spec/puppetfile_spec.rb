require 'spec_helper'
require 'reaktor/r10k/puppetfile'
require 'fileutils'
require 'tmpdir'

describe Reaktor::R10K::Puppetfile do
  let(:logger)  { double('logger').as_null_object }
  let(:branch1) { 'reaktor_test1' }
  let(:branch2) { 'reaktor_test2' }
  let(:branch3) { 'reaktor_test3' }
  let(:mod1) { 'testmod1' }
  let(:mod2) { 'testmod2' }
  let(:mod3) { 'testmod3' }
  let(:repo_name1) { 'testmod1' }
  let(:repo_name2) { 'myproject-testmod2' }
  let(:repo_name3) { 'testmod3' }

  let(:now) { Time.now.strftime('%Y%m%d%H%M%S%L') }
  # let(:puppetfile_orig) { File.new(read_fixture("Puppetfile")) }
  # let(:puppetfile_orig) { File.new('spec/unit/fixtures/Puppetfile') }
  let(:git_work_dir) { Dir.mktmpdir('rspec') }

  before(:each) do
    FileUtils.cp('spec/unit/fixtures/Puppetfile', "#{git_work_dir}/Puppetfile")
  end

  after(:each) do
    FileUtils.remove_entry_secure git_work_dir
  end

  subject { described_class.new(branch1, mod1, logger) }

  it 'should retrieve testmod1 as module name' do
    subject.git_work_dir = git_work_dir
    contents = subject.get_module_name(repo_name1)
    expect(contents).to eq(mod1)
  end

  it 'should update mod testmod1 ref to be branch name' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod1, branch1)
    expect(contents).to include(branch1)
  end

  it 'should write mod testmod1 to Puppetfile correctly' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod1, branch1)
    subject.write_new_puppetfile(contents)
    expect(File.open("#{subject.git_work_dir}/Puppetfile", 'r').read).to include("mod 'testmod1',")
  end

  it 'should retrieve testmod2 as module name' do
    subject.git_work_dir = git_work_dir
    contents = subject.get_module_name(repo_name2)
    expect(contents).to eq(mod2)
  end

  it 'should update mod testmod2 ref to be branch2 name' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod2, branch2)
    expect(contents).to include(branch2)
  end

  it 'should write mod testmod2 to Puppetfile correctly' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod2, branch2)
    subject.write_new_puppetfile(contents)
    expect(File.open("#{subject.git_work_dir}/Puppetfile", 'r').read).to include("mod 'testmod2',")
  end

  it 'should not retrieve testmod3 without `ref` as module name' do
    subject.git_work_dir = git_work_dir
    contents = subject.get_module_name(repo_name3)
    expect(contents).to eq(nil)
  end

  it 'should have contents equal to nil if mod testmod3 doesn\'t have `ref`' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod3, branch3)
    expect(contents).to be_nil
  end

  it 'should not write empty Puppetfile if mod testmod3 doesnt have `ref`' do
    subject.git_work_dir = git_work_dir
    contents = subject.update_module_ref(mod3, branch3)
    subject.write_new_puppetfile(contents)
    expect(File.open("#{subject.git_work_dir}/Puppetfile", 'r').read).to include("mod 'testmod3',")
  end
end
