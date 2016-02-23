# require 'commandrunner'

module Reaktor
  module R10K
    class Puppetfile
      GIT_URL = ENV['PUPPETFILE_GIT_URL'] # || Sinatra::Base.settings.puppetfile_git_url
      attr_accessor :branch, :mod, :git_url, :logger, :git_work_dir, :git_update_ref_msg

      def initialize(branch, mod, logger)
        logger.info("In #{self}")
        @branch = branch
        @mod = mod
        @git_url = GIT_URL
        @logger = logger
        @now = Time.now.strftime('%Y%m%d%H%M%S%L')
        @git_work_dir = File.expand_path("/var/tmp/puppetfile_repo_#{@now}")
        @git_dir = "#{@git_work_dir}/.git"
        @git_cmd = "git --git-dir=#{@git_dir} --work-tree=#{@git_work_dir}"
        @git_update_ref_msg = "changing :ref for #{mod} to #{branch}"
        raise 'PUPPETFILE_GIT_URL not set' unless @git_url
      end

      def loadFile
        File.read("#{@git_work_dir}/Puppetfile")
      end

      # Retrieve the module's name in Puppetfile. Using Puppetfile as source of truth for the module names
      #
      # @param repo_name - The repo name assiociated with the module
      def get_module_name(repo_name)
        pfile = loadFile
        #regex = /mod ["'](\w*)["'],\s*$\n^(\s*):git\s*=>\s*["'].*#{repo_name}.git["'],+(\s*):ref\s*=>\s*['"](\w+|\w+\.\d+\.\d+)['"]$/
        regex = /mod ["'](\w*)["'],\s*$\n^(\s*):git\s*=>\s*["'].*#{repo_name}.git["'],\s*$\n^(\s*):ref\s*=>\s*['"](\w+|\w+\.\d+\.\d+)['"](\s*)$/
        new_contents = pfile.match(regex)
        if new_contents
          module_name = new_contents[1]
        else
          logger.info("ERROR - VERIFY YOU PUPPETFILE SYNTAX - Repository: #{repo_name} - Git url: #{@git_url}")
        end
        module_name
      end

      # update the module ref in Puppetfile
      #
      # @param module_name - The module to change the ref for
      # @param branchname - The ref to change for the module
      def update_module_ref(module_name, branchname)
        pfile = loadFile
        regex = /(#{module_name}(\.git)+['"],)+(\s*):ref\s*=>\s*['"](\w+|\w+\.\d+\.\d+)['"]/m
        pfile.gsub!(regex, ''"\\1\\3:ref => '#{branchname}'"''.strip)
      end

      def write_new_puppetfile(contents)
        if contents
          puppetfile = File.open("#{@git_work_dir}/Puppetfile", 'w')
          puppetfile.write(contents)
          puppetfile.close
          p_file_after_write = `cat #{@git_work_dir}/Puppetfile`
          logger.info("modified puppetfile: #{p_file_after_write}")
        else
          logger.info('Wont create empty Puppetfile')
        end
      end
    end
  end
end
