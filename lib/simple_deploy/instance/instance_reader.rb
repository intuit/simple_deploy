module SimpleDeploy
  class InstanceReader

    def initialize(args)
      @logger = args[:logger]
    end

    def list_stack_instances(stack_name)
      @asg_id = auto_scaling_group_id(stack_name)

      return [] unless @asg_id

      asg_instances = auto_scaling.list_instances

      return [] unless asg_instances.any?

      ec2.describe_instance asg_instances
    end

    private

    def ec2
      @ec2 ||= AWS::EC2.new
    end

    def auto_scaling
      @auto_scaling ||= AWS::AutoScalingGroups.new :asg_id => @asg_id
    end

    def cloud_formation
      @cloud_formation ||= AWS::CloudFormation.new :logger => @logger
    end

    def auto_scaling_group_id(stack_name)
      cf_stack_resources = cloud_formation.stack_resources stack_name
      parse_cf_stack_resources cf_stack_resources
    end

    def parse_cf_stack_resources(cf_stack_resources)
      cf_stack_resources.each do |resource|
        if resource['ResourceType'] == 'AWS::AutoScaling::AutoScalingGroup'
          return resource['PhysicalResourceId']
        end
      end
      false
    end
  end
end
