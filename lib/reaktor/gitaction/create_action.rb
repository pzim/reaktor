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
        # logger.info("branch = #{branch_name}")
        @puppetfile_dir.clone
        result = @puppetfile_dir.checkout(branch_name)
        Notification::Notifier.instance.notification = result
      end

      def update_puppet_file
        pfile_contents = @puppetfile.update_module_ref(module_name, branch_name)
        @puppetfile.write_new_puppetfile(pfile_contents)
        pushed = @puppetfile_dir.push(branch_name, @puppetfile.git_update_ref_msg)
        if pushed
          Deployment::Deployer.instance.deploy(branch_name: branch_name)
        else
          Notification::Notifier.instance.notification = "#{self.class.name} Push failed!"
        end
      end

      def cleanup
        @puppetfile_dir.destroy_workdir
      end
    end
  end
end
