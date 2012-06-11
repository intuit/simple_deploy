require 'json'
module SimpleDeploy
  class StackReader

    def initialize(args)
      @sf = Stackster::StackFormater.new args
      @sr = Stackster::StackReader.new args
    end

    def attributes
      @sf.attributes
    end

    def instances
      @sf.instances_public_ip_addresses
    end

    def status
      @sr.status
    end

    def events
      @sr.events
    end

    def outputs
      @sr.outputs
    end

    def resources
      @sr.resources
    end

    def template
      @sr.template
    end

  end
end
