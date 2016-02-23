require 'logger'
require 'resque'
require 'resque/tasks'

module Reaktor
  class Envconfig
    # Initialize application logging, resque workers, and the resque config.
    #
    # @param rack_env [String] The rack environment, [development, test, production]
    def self.init_environment(rack_env)
      if rack_env.nil? || rack_env.empty?
        raise 'Cannot init environment: RACK_ENV must be set'
      end
      init_logging(rack_env)
      init_workers(rack_env)
    end

    # Initialize log configuration and ensure that stdout and stderr are kept flushed.
    #
    # @param rack_env [String] The rack environment, [development, test, production]
    def self.init_logging(rack_env)
      STDOUT.sync = true
      STDERR.sync = true
      rack_root = ENV['RACK_ROOT'] || './'
      reaktor_log = ENV['REAKTOR_LOG'] || "#{rack_root}/log/reaktor.log"

      logger = Logger.new(reaktor_log.to_s, Logger::DEBUG)
      logger.debug('in envconfig')

      Resque.logger = logger.clone

      case rack_env
      when 'development', 'test'
        Resque.logger.level = Logger::DEBUG
        logger.info("DEV/TEST: setting logger level to DEBUG")
      when 'production'
        Resque.logger.level = Logger::INFO
        logger.info('PRODUCTION: setting logger level to INFO')
      else
        raise ArgumentError, "Cannot init logging: unknown RACK_ENV #{rack_env}"
      end
    end

    # Initialize resque worker configuration
    #
    # @param rack_env [String] The rack environment, [development, test, production]
    def self.init_workers(rack_env)
      # Better to use the resque_workers.god script to manage the workers
      rack_root = ENV['RACK_ROOT'] || './'
      reaktor_log = ENV['REAKTOR_LOG'] || "#{rack_root}/log/reaktor.log"
      case rack_env

      when 'development', 'test', 'production'
        system("TERM_CHILD=1 QUEUE=resque_create rake resque:work >> #{reaktor_log} &")
        system("TERM_CHILD=1 QUEUE=resque_modify rake resque:work >> #{reaktor_log} &")
        system("TERM_CHILD=1 QUEUE=resque_delete rake resque:work >> #{reaktor_log} &")

      else
        raise ArgumentError, "Cannot init resque workers: unknown RACK_ENV #{rack_env}"
      end
    end

    # Render the contents of config/database.yml as a hash.
    #
    # @param rack_env [String] The rack environment, usually one of 'production',
    #   'test', 'development'
    #
    # @return [Hash] The database configuration in the given environment
    def self.dbconfig(_rack_env)
      YAML.load_file('config/resque.yml')
    end
  end
end
