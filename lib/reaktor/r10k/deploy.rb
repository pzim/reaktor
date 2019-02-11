require 'commandrunner'
require 'net/ping'

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
      servers_available = puppetservers_available
      unless servers_available.empty?
        logger.error("FAIL! Not all puppetservers are available: #{servers_available.join','}")
        raise "Not all Puppetservers are available: #{servers_available.join','}"
      end
      @cap_command = cap_command
      result = execute_cap(@cap_command)
    end

    def puppetservers_available
      unavailable_servers = []
      puppetservers = get_puppetservers
      puppetservers.each do | puppetserver |
        check = Net::Ping::External.new(puppetserver.chomp).ping?
        unavailable_servers << puppetserver.chomp unless check
      end
      unavailable_servers
    end

    def get_puppetservers
      m_file = ENV['REAKTOR_PUPPET_MASTERS_FILE']
      mastersFile = open(m_file)
      mastersFile.readlines
    end

  end
end
end
