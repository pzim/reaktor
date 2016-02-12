require 'resque'
require 'reaktor/event_jobs'
require 'reaktor/gitaction'
require 'logger'
# needed temporarily to test
require 'reaktor/notification/notifier'

module Reaktor
  module Jobs
    class Controller
      attr_reader :created, :deleted, :json

      def initialize(json, logger)
        @json = json
        @logger = logger || Logger.new(STDOUT, Logger::INFO)
      end

      ##
      # enqueue the event job
      # @param event_class - event class [CreateEvent, ModifyEvent, DeleteEvent]
      # @param repo_name - name of the repo_name (for the module)
      # @param branch_name - name of the branch
      def enqueue_event(event_class, repo_name, branch_name)
        Resque.enqueue(event_class, repo_name, branch_name)
      end
    end
  end
end
