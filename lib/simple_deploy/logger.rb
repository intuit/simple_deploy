module SimpleDeploy
  class SimpleDeployLogger
    
    def initialize(args = {})
      @logger = args[:logger] ||= Logger.new(STDOUT)
      @log_level = args[:log_level] ||= 'info'

      unless args[:logger]
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{datetime}: #{msg}\n"
        end
      end

      case @log_level.downcase
      when 'info'
        @logger.level = Logger::INFO
      when 'debug'
        @logger.level = Logger::DEBUG
      when 'warn'
        @logger.level = Logger::WARN
      when 'error'
        @logger.level = Logger::ERROR
      end
      @logger
    end

    def debug(msg)
      @logger.debug msg
    end

    def info(msg)
      @logger.info msg
    end

    def error(msg)
      @logger.error msg
    end
  end
end
