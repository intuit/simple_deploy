module SimpleDeploy
  class Status

    def initialize(args)
      @name = args[:name]
      @config = args[:config]
      @logger = @config.logger
    end

    def complete?
      /_COMPLETE$/ === current
    end

    def failed?
      /_FAILED$/ === current
    end

    def cleanup_in_progress?
      /_CLEANUP_IN_PROGRESS$/ === current
    end

    def in_progress?
      /_IN_PROGRESS$/ === current && !cleanup_in_progress?
    end

    def create_failed?
      'CREATE_FAILED' == current
    end

    def stable?
      (complete? || failed?) && (! create_failed?)
    end

    def wait_for_stable(count=25)
      1.upto(count).each do |c|
        break if stable?
        @logger.info ("#{@name} not stable (#{current}).  Sleeping #{c * c} second(s).")
        Kernel.sleep (c * c)
      end
      stable?
    end

    private

    def current
      stack_reader.status
    end

    def stack_reader
      @stack_reader ||= StackReader.new :name   => @name,
                                        :config => @config
    end
  end
end
