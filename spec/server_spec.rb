require 'spec_helper'

require 'reaktor/event_jobs'

describe Reaktor::Server do
  describe 'GET /' do
    it 'returns the index page' do
      get '/'
      expect(last_response.body).to include('Reaktor')
    end
  end

  describe 'Given the url /github_payload' do
    context 'when it recieves a POST without a payload' do
      it 'then it should return status:400' do
        post '/github_payload'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Missing payload')
      end
    end

    context 'when it recieves a malformed payload' do
      github_create_payload = {
        repository: {
        },
        created: true,
        deleted: false,
        ref: 'refs/heads/feature'
      }.to_json

      it "then it responds with status:400 and a message of 'Malformed payload'" do
        post '/github_payload',
             github_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Malformed payload: key not found:')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
      end
    end

    context 'when it recieves a "create" github payload' do
      github_create_payload = {
        repository: {
          name: 'foo-bar'
        },
        created: true,
        deleted: false,
        ref: 'refs/heads/feature'
      }.to_json

      it "then it queues a Reaktor::Jobs::CreateEvent with a payload of #{github_create_payload} in the :resque_create queue" do
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        post '/github_payload',
             github_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Creating environment \'feature\'.')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::CreateEvent).to have_queued('foo-bar', 'feature').in(:resque_create)
      end
    end
    context 'when it recieves a "modify" github payload' do
      github_modify_payload = {
        repository: {
          name: 'foo-bar'
        },
        created: false,
        deleted: false,
        ref: 'refs/heads/feature'
      }.to_json

      it "then it queues a Reaktor::Jobs::ModifyEvent with a payload of #{github_modify_payload} in the :resque_modify queue" do
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
        post '/github_payload',
             github_modify_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Modifying environment \'feature\'.')
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::ModifyEvent).to have_queued('foo-bar', 'feature').in(:resque_modify)
      end
    end
    context 'when it recieves a "delete" github payload' do
      github_delete_payload = {
        repository: {
          name: 'foo-bar'
        },
        created: false,
        deleted: true,
        ref: 'refs/heads/feature'
      }.to_json
      it "then it queues a Reaktor::Jobs:DeleteEvent with a payload of #{github_delete_payload} in the :reaktor_delete queue" do
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        post '/github_payload',
             github_delete_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Deleting environment \'feature\'.')
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::DeleteEvent).to have_queued('foo-bar', 'feature').in(:resque_delete)
      end
    end
  end

  describe 'Given The url /gitlab_payload' do
    context 'when it recieves a POST without a payload' do
      it 'then it returns status:400' do
        post '/gitlab_payload'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Missing payload')
      end
    end
    context 'when it recieves a malformed payload' do
      gitlab_create_payload = {
        repository: {
        },
        created: true,
        deleted: false,
        ref: 'refs/heads/feature'
      }.to_json

      it "then it responds with status:400 and a message of 'Malformed payload'" do
        post '/gitlab_payload',
             gitlab_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Malformed payload: key not found:')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
      end
    end
    context 'recieves a "create" gitlab payload' do
      gitlab_create_payload = {
        repository: {
          name: 'foo-bar'
        },
        before: '0000000000000000000000000000000000000000',
        after: '95790bf891e76fee5e1747ab589903a6a1f80f22',
        ref: 'refs/heads/feature'
      }.to_json

      it "queues a Reaktor::Jobs:CreateEvent with a payload of #{gitlab_create_payload} in the :reaktor_create queue" do
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        post '/gitlab_payload',
             gitlab_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Creating environment \'feature\'.')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::CreateEvent).to have_queued('foo-bar', 'feature').in(:resque_create)
      end
    end
    context 'recieves a "modify" gitlab payload' do
      gitlab_modify_payload = {
        repository: {
          name: 'foo-bar'
        },
        before: 'da1560886d4f094c3e6c9ef40349f7d38b5d27d7',
        after: '95790bf891e76fee5e1747ab589903a6a1f80f22',
        ref: 'refs/heads/feature'
      }.to_json

      it "queues a Reaktor::Jobs:ModifyEvent with a payload of #{gitlab_modify_payload} in the :reaktor_modify queue" do
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
        post '/gitlab_payload',
             gitlab_modify_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Modifying environment \'feature\'.')
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::ModifyEvent).to have_queued('foo-bar', 'feature').in(:resque_modify)
      end
    end
    context 'recieves a "delete" gitlab payload' do
      gitlab_delete_payload = {
        repository: {
          name: 'foo-bar'
        },
        before: '95790bf891e76fee5e1747ab589903a6a1f80f22',
        after: '0000000000000000000000000000000000000000',
        ref: 'refs/heads/feature'
      }.to_json

      it "queues a Reaktor::Jobs:DeleteEvent with a payload of #{gitlab_delete_payload} in the :reaktor_delete queue" do
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        post '/gitlab_payload',
             gitlab_delete_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Deleting environment \'feature\'.')
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::DeleteEvent).to have_queued('foo-bar', 'feature').in(:resque_delete)
      end
    end
  end
  describe 'Given The url /stash_payload' do
    context 'when it recieves a POST without a payload' do
      it 'then it returns status:400' do
        post '/stash_payload'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Missing payload')
      end
    end
    context 'when it recieves a malformed payload' do
      stash_create_payload = {
        repository: {
        }
      }.to_json

      it "then it responds with status:400 and a message of 'Malformed payload'" do
        post '/stash_payload',
             stash_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_bad_request
        expect(last_response.body).to include('Malformed payload: key not found:')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
      end
    end
    context 'recieves a "create" stash payload' do
      stash_create_payload = {
        repository: {
          name: 'foo-bar'
        },
        refChanges: [{
          refId: 'refs/heads/feature',
          fromHash: '0000000000000000000000000000000000000000',
          toHash: '30f6aabc3f5024aadce4f301287fa4f6d84f185d'
        }]
      }.to_json

      it "queues a Reaktor::Jobs:CreateEvent with a payload of #{stash_create_payload} in the :reaktor_create queue" do
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(0)
        post '/stash_payload',
             stash_create_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Creating environment \'feature\'.')
        expect(Reaktor::Jobs::CreateEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::CreateEvent).to have_queued('foo-bar', 'feature').in(:resque_create)
      end
    end
    context 'recieves a "modify" stash payload' do
      stash_modify_payload = {
        repository: {
          name: 'foo-bar'
        },
        refChanges: [{
          refId: 'refs/heads/feature',
          fromHash: '95790bf891e76fee5e1747ab589903a6a1f80f22',
          toHash: '30f6aabc3f5024aadce4f301287fa4f6d84f185d'
        }]
      }.to_json

      it "queues a Reaktor::Jobs:ModifyEvent with a payload of #{stash_modify_payload} in the :reaktor_modify queue" do
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(0)
        post '/stash_payload',
             stash_modify_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Modifying environment \'feature\'.')
        expect(Reaktor::Jobs::ModifyEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::ModifyEvent).to have_queued('foo-bar', 'feature').in(:resque_modify)
      end
    end
    context 'recieves a "delete" stash payload' do
      stash_delete_payload = {
        repository: {
          name: 'foo-bar'
        },
        refChanges: [{
          refId: 'refs/heads/feature',
          fromHash: '30f6aabc3f5024aadce4f301287fa4f6d84f185d',
          toHash: '0000000000000000000000000000000000000000'
        }]
      }.to_json

      it "queues a Reaktor::Jobs:DeleteEvent with a payload of #{stash_delete_payload} in the :reaktor_delete queue" do
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(0)
        post '/stash_payload',
             stash_delete_payload,
             'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        expect(last_response.body).to include('Deleting environment \'feature\'.')
        expect(Reaktor::Jobs::DeleteEvent).to have_queue_size_of(1)
        expect(Reaktor::Jobs::DeleteEvent).to have_queued('foo-bar', 'feature').in(:resque_delete)
      end
    end
  end
end
