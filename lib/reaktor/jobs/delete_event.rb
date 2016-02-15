module Reaktor
  module Jobs
    class DeleteEvent
      include Event

      @queue = :resque_delete
      @logger ||= Logger.new(STDOUT, Logger::INFO)

      def self.perform(module_name, branch_name)
        @options = { module_name: module_name,
                     branch_name: branch_name,
                     logger: @logger
        }
        Redis::Lock.new(branch_name, expiration: 30).lock do
          # do  your stuff here ...
          action = Reaktor::GitAction::DeleteAction.new(@options)
          action.setup
          action.delete_puppetfile_branch
          action.cleanup
        end
      end
    end
  end
end
