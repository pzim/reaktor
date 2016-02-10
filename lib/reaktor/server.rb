# web app libraries
require 'json'
require 'sinatra/base'
require 'sinatra/config_file'

require 'reaktor/gitaction'
require 'reaktor/event_jobs'
require 'reaktor/r10k'

module Reaktor
  class Server < Sinatra::Base
    set :root,  ENV['RACK_ROOT'] || File.expand_path('.')
    konfig_file = ENV['REAKTOR_CONF'] || File.join(root, 'config', 'reaktor.yml')

    # set :show_exceptions, :after_handler

    register Sinatra::ConfigFile
    config_file konfig_file
    logger ||= Logger.new(File.join(settings.logdir.to_s, "reaktor_#{environment}.log"), Logger::INFO)

    get '/' do
      if settings.development?
        "
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset=\"utf-8\" />
                <title>Reaktor</title>
            </head>
            <body>
              <h3>Reaktor</h3>
              <p>a< href=\"https://github.com/pzim/reaktor\"> Docs</a></p>
              <dl>
              <dt>Environment</dt><dd>#{settings.environment}</dd>
              <dt>Root</dt><dd>#{settings.root}</dd>
              </dl>
            </body>
        </html>
        "
      else
        "
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset=\"utf-8\" />
                <title>Reaktor</title>
            </head>
            <body>
              <h3>Reaktor</h3>
            </body>
        </html>
        "
      end
    end

    # endpoint for github/github enterprise payloads
    post '/github_payload' do
      json_payload = json
      logger.info("github payload = #{json_payload}")
      halt 400, 'Missing payload' unless json_payload
      github_controller = Reaktor::Jobs::GitHubController.new(json_payload, @logger)
      begin
        msg = github_controller.process_event
        logger.info(msg)
        { msg: msg }.to_json
      rescue KeyError => e
        halt 400, { msg: "Malformed payload: #{e.message}" }.to_json
      end
    end

    post '/gitlab_payload' do
      json_payload = json
      logger.info("gitlab payload = #{json_payload}")
      halt 400, 'Missing payload' unless json_payload
      gitlab_controller = Reaktor::Jobs::GitLabController.new(json_payload, @logger)
      begin
        msg = gitlab_controller.process_event
        logger.info(msg)
        { msg: msg }.to_json
      rescue KeyError => e
        halt 400, { msg: "Malformed payload: #{e.message}" }.to_json
      end
    end

    post '/stash_payload' do
      json_payload = json
      logger.info("stash payload = #{json_payload}")
      halt 400, 'Missing payload' unless json_payload
      stash_controller = Reaktor::Jobs::StashController.new(json_payload, @logger)
      begin
        msg = stash_controller.process_event
        logger.info(msg)
        { msg: msg }.to_json
      rescue KeyError => e
        halt 400, { msg: "Malformed payload: #{e.message}" }.to_json
      end
    end

    ##
    # Log a simple INFO message using the request.path_info method.
    def log(msg)
      logger.info "[#{request.path_info}] #{msg}"
    end

    def response_headers
      @response_headers ||= { 'Content-Type' => 'application/json' }
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
