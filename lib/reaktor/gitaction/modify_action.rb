module Reaktor
module GitAction
  class ModifyAction < Action
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
    def updatePuppetfile
      self.module_name = @puppetfile.get_module_name(self.module_name)
      pfile_contents = @puppetfile.update_module_ref(self.module_name, self.branch_name)
      @puppetfile.write_new_puppetfile(pfile_contents)
      @puppetfile_dir.push(self.branch_name, @puppetfile.git_update_ref_msg)
      Notification::Notifier.instance.send_message("Environment `#{self.branch_name}` (`#{module_name}`) triggered an r10k deploy")
      begin
        # r10k_deploy_module self.module_name
        Notification::Notifier.instance.send_message("Deploying environment #{self.branch_name}")
        r10k_deploy_env self.branch_name
      rescue => e
        #Send failure alert to default room and ALSO to escalation room that is less noisy
        Notification::Notifier.instance.send_message(":sad_face_cowboy: ABORTING r10k deploy for environment `#{self.branch_name}` (`#{module_name}`) due to: #{e.message}")
        Notification::Notifier.instance.send_message(":sad_face_cowboy: ABORTING r10k deploy for environment `#{self.branch_name}` (`#{module_name}`) due to: #{e.message}", 'kernels_shield')
      else
        Notification::Notifier.instance.send_message(":success: Environment `#{self.branch_name}` finished")
      end
    end
    def cleanup
      @puppetfile_dir.destroy_workdir
    end
  end
end
end
   


