require 'logger'
require 'open3'
require 'reaktor/notification/notifier'

module Reaktor
  #  class CommandRunner
  module CommandRunner
    # read each line from stream and html format the newlines, then send notification
    def read_stream(label, stream)
      @stdout_msg = ''
      @stderr_msg = ''
      begin
        while line = stream.gets
          if label.eql? 'STDOUT'
            @stdout_msg << "#{line}<br>"
          else
            @stderr_msg << "#{line}<br>"
          end
        end
      rescue Exception
        if label.eql? 'STDOUT'
          @stdout_msg << 'Something went wrong with command: {$ERROR_INFO}'
        else
          @stderr_msg << 'Something went wrong with command: {$ERROR_INFO}'
        end
      end
      @logger.debug("######### STDOUT Message size = #{@stdout_msg.length}")
      @logger.debug("######### STDERR Message size = #{@stderr_msg.length}")
      unless @stdout_msg.length < 1
        Notification::Notifier.instance.notification = @stdout_msg
      end
      unless @stderr_msg.length < 1
        Notification::Notifier.instance.notification = @stderr_msg
      end
    end

    # read each line from capistrano stream and html format the newlines, then send notification
    # def read_cap_stream(stream, action)
    # @msg = ''
    # begin
    # while line = stream.gets
    # @logger.debug("line: #{line}")
    # if action.eql? 'update_environment'
    # if line.include?('WARN') || line.include?('Sync') || line.include?('failed') || line.include?('finished')
    # @msg << "#{line}<br>"
    # end
    # else # action = deploy_module
    # if line.include?('Sync') || line.include?('failed') || line.include?('finished')
    # @msg << "#{line}<br>"
    # end
    # end
    # end
    # rescue Exception
    # @msg << "Something went wrong with cap #{action}: {$ERROR_INFO}"
    # end

    # Notification::Notifier.instance.notification = @msg
    # end

    # takes an array consisting of main command and options
    def execute(command)
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      cmd = command.join(' ')
      @logger.info("cmdRunner.cmd = #{cmd}")
      @exit_status = nil
      Open3.popen3(cmd) do |_stdin, stdout, stderr, thr|
        t1 = Thread.new { read_stream('STDOUT', stdout) }
        t2 = Thread.new { read_stream('STDERR', stderr) }
        t1.join
        t2.join
        @exit_status = thr.value
        @logger.info("cmdRunner.exit_status = #{@exit_status}")
        if @exit_status.exitstatus == 0
          @logger.info("stdout msg = #{@stdout_msg}")
        else
          @logger.info("stderr msg = #{@stderr_msg}")
        end
      end
      @exit_status
    end

    # takes an array consisting of main capistrano command and options
    # def execute_cap(command)
    #  cap update_environment -s branchname=dev_RSN_592
    # @logger ||= Logger.new(STDOUT, Logger::INFO)
    # @action = command[1] # either deploy_module or update_environment
    # cmd = command.join(' ')
    # @logger.info("cmdRunner.cmd = #{cmd}")
    # @logger.info("cmdRunner action = #{@action}")
    # @exit_status = nil
    # Open3.popen3(cmd) do |_stdin, _stdout, stderr, thr|
    # t1 = Thread.new { read_cap_stream(stderr, @action) }
    # t1.join
    # @cap_exit = thr.value
    # @logger.info("cmdRunner.cap_exit = #{@cap_exit}")
    # @logger.info("cmdRunner.cap_exit_status = #{@cap_exit.exitstatus}")
    #    @logger.info("msg = #{@msg}")
    # end
    # @cap_exit
    # end
  end
end
