require 'logger'
require 'reaktor/event_jobs'
require 'reaktor/gitaction'

module Reaktor
  module Jobs
    class StashController < Controller
      # process the event - enqueue and let the relevant action class
      # do the processing
      def process_event
        logger = @logger
        @git_payload = Reaktor::Utils::StashPayload.new(@json)
        repo_name = @git_payload.repo_name
        ref_type = @git_payload.ref_type
        branch_name = @git_payload.branch_name
        @created = @git_payload.created
        @deleted = @git_payload.deleted

        if @created && isBranch(ref_type)
          msg = "Creating environment '#{branch_name}'."
          enqueue_event(CreateEvent, repo_name, branch_name)
        end

        if @deleted && isBranch(ref_type)
          msg = "Deleting environment '#{branch_name}'."
          enqueue_event(DeleteEvent, repo_name, branch_name)
        end

        if !@created && !@deleted
          msg = "Modifying environment '#{branch_name}'."
          enqueue_event(ModifyEvent, repo_name, branch_name)
        end
        logger.info(msg)
        msg
      end

      def isBranch(refType)
        refType == 'heads'
      end
    end
  end
end
