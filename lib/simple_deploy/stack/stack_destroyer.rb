module SimpleDeploy
  class Stack
    class StackDestroyer

      def initialize(args)
        @config = args[:config]
        @name = args[:name]
      end

      def destroy
        cloud_formation.destroy @name
      end

      private

      def cloud_formation
        @cf ||= AWS::CloudFormation.new :config => @config
      end

    end
  end
end
