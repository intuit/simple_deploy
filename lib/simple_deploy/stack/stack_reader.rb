module SimpleDeploy
  class StackReader

    def initialize(args)
      @name = args[:name]
      @config = ResourceManager.instance.config
      @logger = args[:logger]
    end

    def attributes
      entry.attributes
    end

    def outputs
      cloud_formation.stack_outputs @name
    end

    def status
      cloud_formation.stack_status @name
    end

    def events(limit)
      cloud_formation.stack_events @name, limit
    end

    def resources
      cloud_formation.stack_resources @name
    end

    def template
      cloud_formation.template @name
    end

    def parameters
      json = JSON.parse template
      json['Parameters'].nil? ? [] : json['Parameters'].keys
    end

    def instances
      instance_reader.list_stack_instances @name
    end

    private

    def entry
      @entry ||= Entry.find :name => @name, :logger => @logger
    end

    def cloud_formation
      @cloud_formation ||= AWS::CloudFormation.new :logger => @logger
    end

    def instance_reader
      @instance_reader ||= InstanceReader.new :logger => @logger
    end
  end
end
