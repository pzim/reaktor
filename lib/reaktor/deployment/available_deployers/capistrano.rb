require 'reaktor/deployment/base_deployer'

module Deployers
  class Capistrano < BaseDeployer
    # The callback method for this observer
    def update(module_name, branch_name)
      @logger.info("In #{self}: Updating - module_name=#{module_name}, branch_name=#{branch_name}")
      if branch_name
        r10k_deploy_env(branch_name)
      else
        r10k_deploy_module(module_name)
      end
    end

    # call capistrano task to deploy env to all masters using r10k
    def r10k_deploy_env(branch_name)
      cap_cmd = ['cap', 'update_environment', '-s', "branch_name=#{branch_name}"]
      _deploy cap_cmd
    end

    # call capistrano task to deploy module to all masters using r10k
    def r10k_deploy_module(module_name)
      cap_cmd = ['cap', 'deploy_module', '-s', "module_name=#{module_name}"]
      _deploy cap_cmd
    end

    def _deploy(cap_command)
      @cap_command = cap_command
      # cmd_runner = Reaktor::CommandRunner.new()
      execute_cap(@cap_command)
    end

    # takes an array consisting of main capistrano command and options
    def execute_cap(command)
      # cap update_environment -s branchname=dev_RSN_592
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      @action = command[1] # either deploy_module or update_environment
      cmd = command.join(' ')
      @logger.info("cmdRunner.cmd = #{cmd}")
      @logger.info("cmdRunner action = #{@action}")
      @exit_status = nil
      Open3.popen3(cmd) do |_stdin, _stdout, stderr, thr|
        t1 = Thread.new { read_cap_stream(stderr, @action) }
        t1.join
        @cap_exit = thr.value
        @logger.info("cmdRunner.cap_exit = #{@cap_exit}")
        @logger.info("cmdRunner.cap_exit_status = #{@cap_exit.exitstatus}")
        # @logger.info("msg = #{@msg}")
      end
      @cap_exit
    end

    # read each line from capistrano stream and html format the newlines, then send notification
    def read_cap_stream(stream, action) # rubocop:disable CyclomaticComplexity,PerceivedComplexity
      @msg = ''
      begin
        while line = stream.gets # rubocop:disable AssignmentInCondition
          @logger.debug("line: #{line}")
          if action.eql? 'update_environment'
            if line.include?('WARN') || line.include?('Sync') || line.include?('failed') || line.include?('finished')
              @msg << "#{line}<br>"
            end
          elsif action.eql? 'deploy_module'
            if line.include?('Sync') || line.include?('failed') || line.include?('finished')
              @msg << "#{line}<br>"
            end
          end
        end
      rescue StandardError
        @msg << "Something went wrong with cap #{action}: {$ERROR_INFO}"
      end
      Notification::Notifier.instance.notification = @msg
    end
  end
end
