require 'fog'

module SimpleDeploy
  class AWS
    class AutoScalingGroups

      def initialize(args)
        c = SimpleDeploy.config
        @asg_id = args[:asg_id]
        @connect = Fog::AWS::AutoScaling.new :aws_access_key_id => c.access_key,
                                             :aws_secret_access_key => c.secret_key,
                                             :region => c.region
      end

      def list_instances
        body = @connect.describe_auto_scaling_groups('AutoScalingGroupNames' => [@asg_id]).body
        result = body['DescribeAutoScalingGroupsResult']['AutoScalingGroups'].last
        result['Instances'].map { |info| info['InstanceId'] }
      end
    end
  end
end
