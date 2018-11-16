require 'singleton'
require 'slack-notifier'
require 'yaml'

module Reaktor
module Notification
  class Notifier
    include Singleton

    attr_accessor :notification

    def initialize
      @config = YAML.load_file(('config/notifiers.yml'))
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      @logger.info("NOTIFICATION initialised")
    end

    def self.send_message(message,room='default')
      @logger.info("NOTIFIER room: #{room}")
      webhook_uri = @config['notifiers'][room]
      @logger.info("NOTIFIER webhook_uri #{webhook_uri}")
      @logger.info("NOTIFIER delivering message via slack")
      notifier = Slack::Notifier.new(webhook_uri)
      notifier.ping message
    end

  end
end
end
