require 'spec_helper'

describe SimpleDeploy::AWS::InstanceReader do
  include_context 'double stubbed logger'
  include_context 'double stubbed config', :access_key => 'key',
                                           :secret_key => 'XXX',
                                           :region     => 'us-west-1'

  describe "list_stack_instances" do
    before do
      @cloud_formation_mock          = mock 'cloud formation'
      @auto_scaling_groups_mock      = mock 'auto scaling'
      @ec2_mock                      = mock 'ec2'

      instances = ['first',{ 'Instances' => [{ 'InstanceId' => 'i-000001' },
                                             { 'InstanceId' => 'i-000002' }] }]
      body =  { 'DescribeAutoScalingGroupsResult' => { 'AutoScalingGroups' => instances } }
      @list_response = stub 'Fog::Response', :body => body, :any? => true

      empty_body =  { 'DescribeAutoScalingGroupsResult' => { 'AutoScalingGroups' => [] } }
      @empty_response = stub 'Fog::Response', :body => empty_body

      @describe_response = stub 'Excon::Response', :body => {
        'reservationSet' => [{
          'instanceSet' => [{'instanceState' => {'name' => 'running'}},
                            {'ipAddress' => '54.10.10.1'},
                            {'instanceId' => 'i-123456'},
                            {'privateIpAddress' => '192.168.1.1'}]}]
      }

      SimpleDeploy::AWS::CloudFormation.stub(:new).
                                        and_return @cloud_formation_mock
    end

    context "with no ASGs" do
      before do
        @cloud_formation_mock.should_receive(:stack_resources).
                              with('stack').
                              and_return []
      end

      it "should return an empty array" do
        instance_reader = SimpleDeploy::AWS::InstanceReader.new
        instance_reader.list_stack_instances('stack').should == []
      end
    end

    context "with an ASG" do
      before do
        stack_resource_results = [{'StackName' => 'stack',
                                   'ResourceType' => 'AWS::AutoScaling::AutoScalingGroup',
                                   'PhysicalResourceId' => 'asg1', 'PhysicalResourceId' => 'asg2'}]

        @cloud_formation_mock.should_receive(:stack_resources).
                              with('stack').
                              and_return stack_resource_results

        Fog::AWS::AutoScaling.stub(:new).
                              and_return @auto_scaling_groups_mock
      end

      context "with no running instances" do
        it "should return empty array" do
          @auto_scaling_groups_mock.should_receive(:describe_auto_scaling_groups).
                                    with('AutoScalingGroupNames' => ['asg1','asg2']).
                                    and_return(@empty_response)

          instance_reader = SimpleDeploy::AWS::InstanceReader.new
          instance_reader.list_stack_instances('stack').should == []
        end
      end

      context "with running instances" do
        it "should return the reservation set for each running instance" do
          @auto_scaling_groups_mock.should_receive(:describe_auto_scaling_groups).
                                    with('AutoScalingGroupNames' => ['asg1','asg2']).
                                    and_return(@list_response)

          Fog::Compute::AWS.stub(:new).
                            and_return @ec2_mock
          @ec2_mock.should_receive(:describe_instances).
                    with('instance-state-name' => 'running',
                         'instance-id' => ['i-000001', 'i-000002']).
                    and_return @describe_response

          instance_reader = SimpleDeploy::AWS::InstanceReader.new
          instance_reader.list_stack_instances('stack').should == [{
            'instanceSet' => [{'instanceState' => {'name' => 'running'}},
                              {'ipAddress' => '54.10.10.1'},
                              {'instanceId' => 'i-123456'},
                              {'privateIpAddress' => '192.168.1.1'}]}]
        end
      end
    end
  end
end
