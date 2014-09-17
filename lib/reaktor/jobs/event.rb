require 'resque'
require 'resque-retry'
require 'redis-objects'
require 'logger'
require 'gitaction'
require 'event_jobs'

module Reaktor
  module Jobs
    module Event
      extend Resque::Plugins::Retry
      # directly enqueue job when lock occurred
      @retry_delay = 0
      # we don't need the limit because sometimes the lock should be cleared
      @retry_limit = 10000
      # just catch lock timeouts
      @retry_exceptions = [Redis::Lock::LockTimeout]
      # logger
      @logger ||= Logger.new(STDOUT, Logger::INFO)
    end
  end
end
   


