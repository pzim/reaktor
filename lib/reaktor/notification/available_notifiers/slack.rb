#require 'slack-api'
require 'logger'

## Dummy slack.rb notifier template. Use as a reference to implement a functional slack notifier
module Notifiers
  class Slack
    include Singleton
    include Observable

    attr_accessor :notification

    def initialize
      @notification = nil
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      env          = ENV.to_hash
      token        = env['REAKTOR_SLACK_TOKEN']
      @room_id     = env['REAKTOR_SLACK_ROOM']
      @from        = env['REAKTOR_SLACK_FROM']
      @slack       = SLACK::API.new(token)
      @logger.info("token = #{token}")
      # ensure room_id exists
      if not slack_room_exist? @room_id
        @logger.info("The defined room_id: #{@room_id} does not exist.")
        @logger.info("Slack messages cannot be sent until a valid room is defined.")
      end
    end

    # The callback method for this observer
    def update(message)
      @logger.info("#{self}: #{message}")
      # Implement the slack message handling here
      @notification = message
      # send the notification to a slack room defined above
    end

    def slack_room_exist?(room_name)
      #implement slack-specific logic here
    end

  end
end
