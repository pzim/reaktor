module Reaktor
  module GitAction
    class CreateAction < Action
      def initialize(options = {})
        super(options)
        @puppetfile = R10K::Puppetfile.new(branch_name, module_name, logger)
        @puppetfile_dir = Git::WorkDir.new(@puppetfile.git_work_dir, @puppetfile.git_url)
        logger.info("In #{self}")
      end

      def setup
        logger.info("branch = #{branch_name}")
        @puppetfile_dir.clone
        @puppetfile_dir.checkout(branch_name)
      end

      def updatePuppetFile
        pfile_contents = @puppetfile.update_module_ref(module_name, branch_name)
        @puppetfile.write_new_puppetfile(pfile_contents)
        pushed = @puppetfile_dir.push(branch_name, @puppetfile.git_update_ref_msg)
        if pushed
          Notification::Notifier.instance.notification = "r10k deploy environment for #{branch_name} in progress..."
          result = r10k_deploy_env branch_name
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
