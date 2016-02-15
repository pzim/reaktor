require 'logger'
require 'reaktor/r10k'
require 'reaktor/git'
require 'reaktor/notification/notifier'
require 'reaktor/deployment/deployer'

module Reaktor
  module GitAction
    class Action
      attr_accessor :module_name,
                    :branch_name,
                    :puppetfile,
                    :logger

      def initialize(options = {})
        @options = options
        if module_name = options[:module_name]
          @module_name = module_name
        end
        if branch_name = options[:branch_name]
          @branch_name = branch_name
        end
        @logger = if logger = options[:logger]
                    logger
                  else
                    Logger.new(STDOUT)
                  end
      end
    end
  end
end
