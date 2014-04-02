module SimpleDeploy
  class AWS
    class InstanceReader
      def initialize
        @config  = SimpleDeploy.config
      end

      def list_stack_instances(stack_name)

        instances = []
       
        #Nested stack
        nested_stacks = nested_stacks_names(stack_name)
        instances = nested_stacks.map {|stack| list_stack_instances stack }.flatten if nested_stacks.any?

        #Auto Scaling Group
        asg_ids = auto_scaling_group_id(stack_name)
        asg_instances = asg_ids.map { |asg_id| list_instances asg_id }.flatten

        #EC2 instance
        stack_instances = instance_names(stack_name)

        instances += (describe_instances (asg_instances + stack_instances)) if (asg_instances + stack_instances).any?

        instances
      end

      private

      def list_instances(asg_id)
        @asg ||= Fog::AWS::AutoScaling.new :aws_access_key_id     => @config.access_key,
                                           :aws_secret_access_key => @config.secret_key,
                                           :region                => @config.region

        body = @asg.describe_auto_scaling_groups('AutoScalingGroupNames' => [asg_id]).body
        result = body['DescribeAutoScalingGroupsResult']['AutoScalingGroups'].last
        return [] unless result

        result['Instances'].map { |info| info['InstanceId'] }
      end

      def describe_instances(instances)
        @ec2 ||= Fog::Compute::AWS.new :aws_access_key_id     => @config.access_key,
                                       :aws_secret_access_key => @config.secret_key,
                                       :region                => @config.region

        @ec2.describe_instances('instance-state-name' => 'running',
                                'instance-id' => instances).body['reservationSet']
      end

      def cloud_formation
        @cloud_formation ||= AWS::CloudFormation.new
      end

      def auto_scaling_group_id(stack_name)
        cf_stack_resources = cloud_formation.stack_resources stack_name
        parse_cf_stack_resources cf_stack_resources
      end

      def parse_cf_stack_resources(cf_stack_resources)
        asgs = cf_stack_resources.select do |r|
          r['ResourceType'] == 'AWS::AutoScaling::AutoScalingGroup'
        end
        asgs.any? ? asgs.map {|asg| asg['PhysicalResourceId'] } : []
      end

      def nested_stacks_names(stack_name)
        cf_stack_resources = cloud_formation.stack_resources stack_name
        asgs = cf_stack_resources.select do |r|
          r['ResourceType'] == 'AWS::CloudFormation::Stack'
        end
        asgs.any? ? asgs.map {|asg| asg['PhysicalResourceId'] } : []
      end

      def instance_names(stack_name)
        cf_stack_resources = cloud_formation.stack_resources stack_name
        asgs = cf_stack_resources.select do |r|
          r['ResourceType'] == 'AWS::EC2::Instance'
        end
        asgs.any? ? asgs.map {|asg| asg['PhysicalResourceId'] } : []
      end

    end
  end
end
