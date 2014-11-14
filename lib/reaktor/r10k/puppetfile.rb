#require 'commandrunner'

module Reaktor
module R10K
  class Puppetfile
    GIT_URL = ENV['PUPPETFILE_GIT_URL']
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
    end

    def loadFile
      contents = File.read("#{@git_work_dir}/Puppetfile")
    end

    # update the module ref in Puppetfile
    #
    # @param module_name - The module to change the ref for
    # @param branchname - The ref to change for the module
    def update_module_ref(module_name, branchname)
      pfile = loadFile
      regex = /(#{module_name}(\.git)+['"],)+(\s*):ref\s*=>\s*['"](\w+|\w+\.\d+\.\d+)['"]/m
      new_contents = pfile.gsub!(regex, """\\1\\3:ref => '#{branchname}'""".strip)
    end

    def write_new_puppetfile(contents)
      puppetfile = File.open("#{@git_work_dir}/Puppetfile", "w")
      puppetfile.write(contents)
      puppetfile.close()
      p_file_after_write = `cat #{@git_work_dir}/Puppetfile` 
      logger.info("modified puppetfile: #{p_file_after_write}")
    end
  end
end
end
