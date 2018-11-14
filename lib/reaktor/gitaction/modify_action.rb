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
      Notification::Notifier.instance.notification = "Environment `#{self.branch_name}` (`#{module_name}`) triggered an r10k deploy"
      begin
        r10k_deploy_module self.module_name
      rescue => e
        Notification::Notifier.instance.notification = ":sad_face_cowboy: ABORTING r10k deploy for environment `#{self.branch_name}` (`#{module_name}`) due to: #{e.message}"
#        Notification::Notifier.instance(@mattermost_url = env['SLACK_KNL_SHIELD_URL']).notification = ":sad_face_cowboy: ABORTING r10k deploy for environment `#{self.branch_name}` (`#{module_name}`) due to: #{e.message}"
      else
        Notification::Notifier.instance.notification = ":success: Environment `#{self.branch_name}` (`#{module_name}`) finished"
      end
    end
    def cleanup
      @puppetfile_dir.destroy_workdir
    end
  end
end
end
   


