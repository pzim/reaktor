require 'commandrunner'

module Reaktor
module R10K
  module Deploy
    include Reaktor::CommandRunner

    #call capistrano task to deploy env to all masters using r10k
    def r10k_deploy_env(branchname)
      cap_cmd = ["cap", "update_environment", "-s", "branchname=#{branchname}"]
      deploy cap_cmd
    end

    #call capistrano task to deploy module to all masters using r10k
    def r10k_deploy_module(modulename)
      cap_cmd = ["cap", "deploy_module", "-s", "module_name=#{modulename}"]
      deploy cap_cmd
    end

    def deploy(cap_command)
      @cap_command = cap_command
      #cmd_runner = Reaktor::CommandRunner.new()
      result = execute_cap(@cap_command)
    end
                      
  end
end
end
