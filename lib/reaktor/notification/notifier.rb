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
      @logger.info("NOTIFIER delivering slack message to room: #{room}")
      notifier = Slack::Notifier.new(webhook_uri)
      notifier.ping message.chomp
    end

  end
end
end
