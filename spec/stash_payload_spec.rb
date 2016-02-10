require 'spec_helper'
require 'reaktor/utils/stash_payload'
require 'json'

describe Reaktor::Utils::StashPayload do
  let(:json_created_str) { read_fixture('created_stash.json') }
  let(:payload_created) { JSON.load(json_created_str) }

  subject { described_class.new(payload_created) }

  it 'should parse branch_name dev_hook_test' do
    branchname = subject.branch_name
    expect(branchname).to eql 'dev_hook_test'
  end

  it 'created should be true' do
    created = subject.created
    expect(created).to eql true
  end

  it 'deleted should be false' do
    deleted = subject.deleted
    expect(deleted).to eql false
  end

  it 'repo name should be webhook_test_two' do
    repo_name = subject.repo_name
    expect(repo_name).to eql 'webhook_test_two'
  end
end

describe Reaktor::Utils::StashPayload do
  let(:json_deleted_str) { read_fixture('deleted_stash.json') }
  let(:payload_deleted) { JSON.load(json_deleted_str) }

  subject { described_class.new(payload_deleted) }

  it 'should parse branch_name dev_hook_test' do
    branchname = subject.branch_name
    expect(branchname).to eql 'dev_hook_test'
  end

  it 'created should be false' do
    created = subject.created
    expect(created).to eql false
  end

  it 'deleted should be true' do
    deleted = subject.deleted
    expect(deleted).to eql true
  end

  it 'repo name should be webhook_test_two' do
    repo_name = subject.repo_name
    expect(repo_name).to eql 'webhook_test_two'
  end
end
