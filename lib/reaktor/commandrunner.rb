require 'logger'
require 'open3'
require 'notification/notifier'

module Reaktor
#  class CommandRunner
  module CommandRunner

    # read each line from stream and html format the newlines, then send notification 
    def read_stream(label, stream)
      is_stdout = label.eql? 'STDOUT'

      @stdout_msg = ""
      @stderr_msg = ""
      begin
        while line = stream.gets
          if is_stdout
            @stdout_msg << "#{line}"
          else
            @stderr_msg << "#{line}"
          end
        end
      rescue Exception
        if is_stdout
          @stdout_msg << "Something went wrong with command: #{$!}"
        else
          @stderr_msg << "Something went wrong with command: #{$!}"
        end
      end
      @logger.debug("######### STDOUT: #{@stdout_msg}") if is_stdout
      @logger.debug("######### STDERR: #{@stderr_msg}") unless is_stdout

      @stdout_msg.strip!
      @stderr_msg.strip!

      if @stdout_msg.length > 0 and is_stdout
        Notification::Notifier.instance.send_message(@stdout_msg)
      end
      if @stderr_msg.length > 0 and not is_stdout
        Notification::Notifier.instance.send_message(@stderr_msg)
      end
    end

    # read each line from capistrano stream and html format the newlines, then send notification 
    def read_cap_stream(stream, action)
      @msg = ""
      begin
        while line = stream.gets
          @logger.debug("line: #{line}")
          line.gsub!('** [out ::','')
          line.gsub!('net]','net -')
          if action.eql? "update_environment"
            if line.include? "WARN" or line.include? "Sync" or line.include? "failed" or line.include? "finished"
              @msg << "#{line}"
            end
          else #action = deploy_module
            if line.include? "Sync" or line.include? "failed" or line.include? "finished"
              @msg << "#{line}"
            end
          end
        end
      rescue Exception
        @msg << "Something went wrong with cap #{action}: #{$!}"
      end

      Notification::Notifier.instance.send_message(@msg)
    end

    # takes an array consisting of main command and options 
    def execute(command)
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      cmd = command.join(' ')
      @logger.info("cmdRunner.cmd = #{cmd}")
      @exit_status = nil
      Open3.popen3(cmd) do |stdin, stdout, stderr, thr|
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
    def execute_cap(command)
      #cap update_environment -s branchname=dev_RSN_592
      @logger ||= Logger.new(STDOUT, Logger::INFO)
      @action = command[1] # either deploy_module or update_environment
      cmd = command.join(' ')
      @logger.info("cmdRunner.cmd = #{cmd}")
      @logger.info("cmdRunner action = #{@action}")
      @exit_status = nil
      Open3.popen3(cmd) do |stdin, stdout, stderr, thr|
        t1 = Thread.new { read_cap_stream(stderr, @action) }
        t1.join
        @cap_exit = thr.value
        @logger.info("cmdRunner.cap_exit = #{@cap_exit}")
        @logger.info("cmdRunner.cap_exit_status = #{@cap_exit.exitstatus}")
        #@logger.info("msg = #{@msg}")
      end
      @cap_exit
    end
  end
end

