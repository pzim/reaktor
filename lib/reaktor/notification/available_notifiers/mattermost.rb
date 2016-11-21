require 'faraday'
require 'json'
require 'logger'

module Notifiers
  class Mattermost
    include Singleton
    include Observable

    attr_accessor :notification

    def initialize
      @notification = nil
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      env          = ENV.to_hash
      @mattermost_url  = env['REAKTOR_MATTERMOST_URL']
    end

    def update(message)
      @logger.info("#{self}: #{message}")
      @notification = message
      send_message(message)
    end

    private

    def send_message(message)
      message.gsub!('<br>','')
      params = {'username' => 'Reaktor',
                              'text' => message
               }.to_json
      conn = Faraday.new do | faraday |
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn.post do | req |
        req.url @mattermost_url
        req.headers['Content-Type'] = 'application/json'
        req.body = params
      end
    end

  end
end
