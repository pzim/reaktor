require 'observer'
require 'singleton'

module Reaktor
  module Notification
    class Notifier
      include Singleton
      include Observable

      attr_accessor :notification

      def initialize
        # if user wants to override where to look for custom notifiers
        @notifier_dir = ENV['REAKTOR_NOTIFIERS_DIR']
        # if no custom notifier dir found, use default
        current_dir = Dir.pwd
        @notifier_dir ||= "#{current_dir}/lib/reaktor/notification/active_notifiers"
        loadNotifiersAsObservers(@notifier_dir)
      end

      # load all notifiers and add them as observers
      # @param notifier_dir - directory where notifier ruby files live
      def loadNotifiersAsObservers(notifier_dir)
        # dynamically load each notifier found
        Dir.glob("#{notifier_dir}/**/*.rb").each { |f| require f }
        @notification = nil
        @logger ||= Logger.new(STDOUT, Logger::INFO)
        @logger.info("NOTIFIER_DIR = #{notifier_dir}")
        Dir.glob("#{notifier_dir}/*.rb").each do |f|
          @logger.debug("loading notifier from file: #{f}")
          clazz = getClassFromFile(f)
          add_observer(clazz.instance)
        end
      end

      # get the class object from the file it's declared in
      # @param filename - the ruby class file
      # returns the class object name
      def getClassFromFile(filename)
        notifier_base_name = File.basename(filename, '.rb')
        instance_name = notifier_base_name.capitalize
        # split on "::" and iterate the results, returning the last element found,
        # which is the class name we're after
        "Notifiers::#{instance_name}".split('::').inject(Object) { |o, c| o.const_get c }
      end

      # notification method which triggers the observers
      # @param message - the message string to send to all observers
      def notification=(message)
        @notification = message
        changed
        notify_observers(message)
      end
    end
  end
end
