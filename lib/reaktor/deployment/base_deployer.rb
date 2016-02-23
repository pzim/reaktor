require 'observer'
require 'singleton'
require 'reaktor/notification/notifier'

module Deployers
  class BaseDeployer
    include Singleton
    include Observable

    def initialize
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      msg = "#{self.class.name}: Starting Deployment"
      @logger.info(msg)
      Reaktor::Notification::Notifier.instance.notification = msg
    end

    # The callback method for this observer
    def update(branch_name, module_name)
      @logger.info("#{self.class.name}: Not implemented - received: branch_name=#{branch_name} module_name=#{module_name}")
    end
  end
end
