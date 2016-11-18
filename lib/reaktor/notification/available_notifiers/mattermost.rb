require 'faraday'
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
      @logger.info("token = #{token}")
    end

    def update(message)
      @logger.info("#{self}: #{message}")
      @notification = message
      send_message
    end

    private

    def send_message
      params = {payload={"username" : "Reaktor",
                         "text": @notification
                        }
               }
      Faraday.post(@mattermost_url, params)
    end

  end
end
