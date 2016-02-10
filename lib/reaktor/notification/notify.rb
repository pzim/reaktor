require 'logger'
require 'reaktor/notification'

module Reaktor
  module Notification
    class Notify
      attr_accessor :message,
                    :username,
                    :password,
                    :token,
                    :room_id,
                    :from,
                    :logger

      def initialize(options = {})
        @options = options
        if username = options[:username]
          @username = username
        end
        if password = options[:password]
          @password = password
        end
        if api_token = options[:api_token]
          @api_token = api_token
        end
        if room_id = options[:room_id]
          @room_id = room_id
        end
        if from = options[:from]
          @from = from
        end
        if logger = options[:logger]
          @logger = logger
        else
          @logger ||= Logger.new(STDOUT)
        end
      end
    end
  end
end
