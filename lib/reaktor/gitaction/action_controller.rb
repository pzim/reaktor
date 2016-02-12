require 'logger'

module Reaktor
  module GitAction
    class ActionController
      attr_reader :created, :deleted, :json

      def initialize(json)
        @json = json
        @logger ||= Logger.new(STDOUT, Logger::INFO)
      end

      ##
      # action_type returns an instance of an action class.
      # If no action is registered for the GitAction action then `nil` is returned.
      #
      # @return [Reaktor::Action] subclass instance suitable to perform necessary actions
      # , or `nil`.
      def action_type
        logger      = @logger
        repo_name   = @json['repository']['name']
        repo_ref    = @json['ref']
        @created    = @json['created']
        @deleted    = @json['deleted']
        ref_array   = repo_ref.split('/')
        ref_type    = ref_array[1]
        branch_name = ref_array[2]

        if @created && isBranch(ref_type)
          logger.info('Create Action')
          options = { module_name: repo_name,
                      branch_name: branch_name,
                      logger: logger
                    }
          action = Reaktor::GitAction::CreateAction.new(options)
          return action
        end

        if @deleted && isBranch(ref_type)
          logger.info('Delete Action')
          options = { branch_name: branch_name,
                      logger: logger
                    }
          action = Reaktor::GitAction::DeleteAction.new(options)
          return action
        end

        if !@created && !@deleted
          logger.info('Modify Action')
          options = { module_name: repo_name,
                      branch_name: branch_name,
                      logger: logger
                    }
          action = Reaktor::GitAction::ModifyAction.new(options)
          return action
        end
        end

      def isBranch(refType)
        refType == 'heads'
      end
    end
  end
end
