require 'reaktor/deployment/base_deployer'

module Deployers
  class Noop < BaseDeployer
    # The callback method for this observer
    def update(module_name, branch_name)
      @logger.info("In #{self}: Updating - module_name=#{module_name}, branch_name=#{branch_name}")
      Reaktor::Notification::Notifier.instance.notification = "#{self.class.name}: Deployment complete"
    end
  end
end
