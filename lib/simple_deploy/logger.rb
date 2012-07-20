module SimpleDeploy
  class SimpleDeployLogger

    require 'forwardable'

    include Forwardable

    def_delegators :@logger, :debug, :error, :info, :warn

    def initialize(args = {})
      @log_level = args[:log_level] ||= 'info'
      @logger    = args[:logger] ||= new_logger(args)
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

    def logger_level
      Logger.const_get @log_level.upcase
    end

  end
end
