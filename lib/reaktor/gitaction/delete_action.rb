module Reaktor
module GitAction
  class DeleteAction < Action
    def initialize(options = {})
      super(options)
      @puppetfile = R10K::Puppetfile.new(self.branch_name, self.module_name, self.logger)
      @puppetfile_dir = Git::WorkDir.new(@puppetfile.git_work_dir, @puppetfile.git_url)
      logger.info("In #{self}")
    end
    def setup
      logger.info("branch = #{self.branch_name}")
      @puppetfile_dir.clone
    end
    def deletePuppetfileBranch
      Notification::Notifier.instance.send_message("Deleting #{branch_name} from puppetfile repo")
      @puppetfile_dir.deleteBranch(self.branch_name)
    end
    def cleanup
      @puppetfile_dir.destroy_workdir
    end
  end
end
end
