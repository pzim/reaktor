require 'logger'
require 'reaktor/event_jobs'
require 'reaktor/gitaction'

module Reaktor
  module Jobs
    class GitLabController < Controller
      # process the event - enqueue and let the relevant action class
      # do the processing
      def process_event
        logger = @logger
        @git_payload = Reaktor::Utils::GitLabPayload.new(@json)
        repo_name = @git_payload.repo_name
        ref_type = @git_payload.ref_type
        branch_name = @git_payload.branch_name
        @created = @git_payload.created
        @deleted = @git_payload.deleted

        if @created && isBranch(ref_type)
          logger.info('Create Event')
          enqueue_event(CreateEvent, repo_name, branch_name)
          msg = "Creating environment '#{branch_name}'."
        end

        if @deleted && isBranch(ref_type)
          logger.info('Delete Event')
          enqueue_event(DeleteEvent, repo_name, branch_name)
          msg = "Deleting environment '#{branch_name}'."
        end

        if !@created && !@deleted
          logger.info('Modify Event')
          enqueue_event(ModifyEvent, repo_name, branch_name)
          msg = "Modifying environment '#{branch_name}'."
        end
        msg
      end

      def isBranch(refType)
        refType == 'heads'
      end
    end
  end
end
