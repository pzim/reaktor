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

    def send_message(message,room='default')
      return if message.to_s.strip.empty?
      webhook_uri = @config['notifiers'][room]
      if webhook_uri.nil?
        @logger.error("Webhook_uri not found for room #{room}.")
        raise "Webhook_uri not found for room #{room}."
      end
      @logger.info("#{webhook_uri} #{message}")
      notifier = Slack::Notifier.new(webhook_uri)
      notifier.ping message.chomp
    rescue => e
      @logger.error("Exception caught: #{e.class} #{e.message} #{e.backtrace}")
    end

  end
end
end
