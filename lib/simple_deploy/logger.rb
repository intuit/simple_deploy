module SimpleDeploy
  class SimpleDeployLogger
    
    def initialize(args = {})
      @logger = args[:logger] ||= Logger.new(STDOUT)

      unless args[:logger]
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{datetime}: #{msg}\n"
        end
      end

      @logger
    end

    def info(msg)
      @logger.info msg
    end
  end
end
