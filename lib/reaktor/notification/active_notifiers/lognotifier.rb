require 'logger'

module Notifiers
  class Lognotifier
    include Singleton
    include Observable

    attr_accessor :notification

    def initialize
      @notification = nil
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      @logger.info("In: #{self}")
    end

    # The callback method for this observer
    def update(message)
      @logger.info("#{self}: #{message}")
      @notification = message
      @logger.info("Notification: #{@notification}")
    end
  end
end
