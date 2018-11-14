require 'observer'
require 'singleton'
require 'slack-notifier'
require 'yaml'

module Reaktor
module Notification
  class Notifier

    def initialize
      @config = YAML::load(File.open('./config/notifiers.yml'))
    end

    def self.send_message(message,room:'default')
      webhook_uri = @config['notifiers'][room]
      notifier = Slack::Notifier.new(webhook_uri)
      notifier.ping message
    end

  end
end
end
