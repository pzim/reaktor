# web app libraries
require 'json'
require 'sinatra/base'
require 'sinatra/config_file'

require 'gitaction'
require 'event_jobs'
require 'r10k'

require 'logger'

module Reaktor
  class R10KApp < Sinatra::Base

    rack_root   = ENV['RACK_ROOT'] || "/data/apps/sinatra/reaktor"
    reaktor_log = ENV['REAKTOR_LOG'] || "#{rack_root}/reaktor.log"
    logger ||= Logger.new("#{reaktor_log}", Logger::INFO)

    # endpoint for github/github enterprise payloads
    post '/github_payload' do
      jsonPayload = json
      logger.info("github payload = #{jsonPayload}")
      github_controller = Reaktor::Jobs::GitHubController.new(jsonPayload, @logger)
      github_controller.process_event
    end

    post '/gitlab_payload' do
      jsonPayload = json
      logger.info("gitlab payload = #{jsonPayload}")
      gitlab_controller = Reaktor::Jobs::GitLabController.new(jsonPayload, @logger)
      gitlab_controller.process_event
    end

    post '/stash_payload' do
      #jsonPayload = json
      #logger.info("stash payload = #{jsonPayload}")
      #stash_controller = Reaktor::Jobs::GitlabController.new(jsonPayload)
      #stash_controller.process_event
      # not implemented yet
    end

    ##
    # Log a simple INFO message using the request.path_info method.
    def log(msg)
      logger.info "[#{request.path_info}] #{msg}"
    end

    def response_headers
      @response_headers ||= {'Content-Type' => 'application/json'}
    end

    ##
    # Obtain the payload from the request.  If there is Form data, we expect
    # this as a string in the parameter named payload.  If there is no form
    # data, then we expect to the payload to be the body.
    def payload
      if request.form_data?
        request['payload']
      else
        request.body.rewind
        request.body.read
      end
    end

    ##
    # Read and parse the JSON payload.  This assumes the payload method
    # returns a JSON string.
    def json
      @json ||= JSON.load(payload)
    end
  end
end
