module Reaktor
  module GitAction
    class DeleteAction < Action
      def initialize(options = {})
        super(options)
        @puppetfile = R10K::Puppetfile.new(branch_name, module_name, logger)
        @puppetfile_dir = Git::WorkDir.new(@puppetfile.git_work_dir, @puppetfile.git_url)
        logger.info("In #{self}")
      end

      def setup
        logger.info("branch = #{branch_name}")
        @puppetfile_dir.clone
      end

      def deletePuppetfileBranch
        Notification::Notifier.instance.notification = "Deleting #{branch_name} from puppetfile repo"
        @puppetfile_dir.deleteBranch(branch_name)
      end

      def cleanup
        @puppetfile_dir.destroy_workdir
      end
    end
  end
end
