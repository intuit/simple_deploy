module SimpleDeploy
  class StackDestroyer

    def initialize(args)
      @config = ResourceManager.instance.config
      @name = args[:name]
      @logger = args[:logger]
    end

    def destroy
      cloud_formation.destroy @name
    end

    private

    def cloud_formation
      @cf ||= AWS::CloudFormation.new :logger => @logger
    end
  end
end
