require 'spec_helper'
require 'reaktor/jobs/github_controller'
require 'json'

describe Reaktor::Jobs::GitHubController do
  # TODO: change to use fixture
  let :json do
    {
      repository: {
        name: 'foo-bar'
      },
      created: true,
      deleted: false,
      ref: 'refs/heads/feature'
    }.to_json
  end
  let(:logger) { nil }

  subject { described_class.new(json, logger) }
  it 'it should have initialized' do
    is_expected.to have_attributes(json: json)
  end
end
