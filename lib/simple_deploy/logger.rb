module SimpleDeploy
  class SimpleDeployLogger

    require 'forwardable'

    extend Forwardable

    def_delegators :@logger, :debug, :error, :info, :warn

    # For capistrano output
    # Only output Cap commands in debug mode
    def puts(msg, line_prefix=nil)
      @logger.debug msg.chomp
    end

    def initialize(args = {})
      @log_level = args[:log_level] ||= 'info'
      @logger    = args[:logger] ||= new_logger(args)
    end

    def logger_level
      Logger.const_get @log_level.upcase
    end

    # Added to support capistrano version 2.13.5
    def tty?
      nil
    end

    private

    def new_logger(args)
      Logger.new(STDOUT).tap do |l|
        l.datetime_format = '%Y-%m-%dT%H:%M:%S%z'
        l.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} #{severity} : #{msg}\n"
        end
        l.level = logger_level
      end
    end

  end
end
