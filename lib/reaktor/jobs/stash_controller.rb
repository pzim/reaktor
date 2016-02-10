require 'event_jobs'
require 'gitaction'
require 'logger'
require 'event_jobs'

module Reaktor
  module Jobs
    class StashController < Controller
      ##
      # process the event - enqueue and let the relevant action class
      # do the processing
      #
      def process_event
        logger = @logger
        @git_payload = Reaktor::Utils::StashPayload.new(@json)
        repo_name = @git_payload.repo_name
        ref_type = @git_payload.ref_type
        branch_name = @git_payload.branch_name
        @created = @git_payload.created
        @deleted = @git_payload.deleted

        # temp for testing
        # Notification::Notifier.instance.notification = "branch_name = #{branch_name}"

        if @created && isBranch(ref_type)
          logger.info('Create Event')
          enqueue_event(CreateEvent, repo_name, branch_name)
        end

        if @deleted && isBranch(ref_type)
          logger.info('Delete Event')
          enqueue_event(DeleteEvent, repo_name, branch_name)
        end

        if !@created && !@deleted
          logger.info('Modify Event')
          enqueue_event(ModifyEvent, repo_name, branch_name)
        end
      end

      def isBranch(refType)
        refType == 'heads'
      end
    end
  end
end
