require 'observer'
require 'singleton'

module Reaktor
  module Deployment
    class Deployer
      include Singleton
      include Observable

      def initialize
        @deployer_dir = ENV['REAKTOR_DEPLOYERS_DIR']
        @logger ||= Logger.new(STDOUT, Logger::INFO)
        @logger.info("In: #{self}")
        @deployer_dir ||= File.join(File.expand_path(File.dirname(__FILE__)), 'active_deployers')
        loadDeployersAsObservers(@deployer_dir)
      end

      # load all notifiers and add them as observers
      # @param notifier_dir - directory where notifier ruby files live
      def loadDeployersAsObservers(deployer_dir)
        # dynamically load each notifier found
        Dir.glob("#{deployer_dir}/**/*.rb").each { |f| require f }
        @logger.info("DEPLOYER_DIR = #{deployer_dir}")
        Dir.glob("#{deployer_dir}/*.rb").each do |f|
          @logger.debug("loading deployer from file: #{f}")
          clazz = getClassFromFile(f)
          add_observer(clazz.instance)
        end
      end

      # get the class object from the file it's declared in
      # @param filename - the ruby class file
      # returns the class object name
      def getClassFromFile(filename)
        deployer_base_name = File.basename(filename, '.rb')
        instance_name = deployer_base_name.capitalize
        # split on "::" and iterate the results, returning the last element found,
        # which is the class name we're after
        "Deployers::#{instance_name}".split('::').inject(Object) { |o, c| o.const_get c } # rubocop:disable SingleLineBlockParams
      end

      def deploy(module_name = nil, branch_name = nil)
        changed
        notify_observers(module_name, branch_name)
      end
    end
  end
end
