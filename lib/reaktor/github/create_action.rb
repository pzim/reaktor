module Reaktor
module Github
  class CreateAction < Action
    def initialize(options = {})
      super(options)
      @puppetfile = R10K::Puppetfile.new(self.branch_name, self.module_name, self.logger)
      @puppetfile_dir = Git::WorkDir.new(@puppetfile.git_work_dir, @puppetfile.git_url)
      logger.info("In #{self}")
    end
    def setup
      logger.info("branch = #{self.branch_name}")
      @puppetfile_dir.clone
      @puppetfile_dir.checkout(self.branch_name)
    end
    def updatePuppetFile
      pfile_contents = @puppetfile.update_module_ref(self.module_name, self.branch_name)
      @puppetfile.write_new_puppetfile(pfile_contents)
      pushed = @puppetfile_dir.push(self.branch_name, @puppetfile.git_update_ref_msg)
      if pushed
        Notification::Notifier.instance.notification = "r10k deploy environment for #{branch_name} in progress..."
        result = r10k_deploy_env self.branch_name
        if result.exited?
          Notification::Notifier.instance.notification = "r10k deploy environment for #{branch_name} finished"
        end
      end
    end
    def cleanup
      @puppetfile_dir.destroy_workdir
    end
  end
end
end
