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
    end

    def send_message(message,room='default')
      webhook_uri = @config['notifiers'][room]
      if webhook_uri.nil
        @logger.error("Webhook_uri not found.")
        raise "Webhook_uri not found."
      end
      notifier = Slack::Notifier.new(webhook_uri)
      notifier.ping message.chomp
    end

  end
end
end
