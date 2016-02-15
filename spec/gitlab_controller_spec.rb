require 'spec_helper'
require 'reaktor/jobs/gitlab_controller'
require 'json'

describe Reaktor::Jobs::GitLabController do
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
