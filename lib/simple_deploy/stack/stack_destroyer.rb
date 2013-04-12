module SimpleDeploy
  class StackDestroyer

    def initialize(args)
      @config = SimpleDeploy.config
      @name = args[:name]
    end

    def destroy
      cloud_formation.destroy @name
    end

    private

    def cloud_formation
      @cf ||= AWS::CloudFormation.new
    end
  end
end
