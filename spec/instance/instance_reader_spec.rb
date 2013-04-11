require 'spec_helper'

describe SimpleDeploy::InstanceReader do

  describe "list_stack_instances" do

    before do
      @logger_mock                   = mock 'logger'
      @cloud_formation_mock          = mock 'cloud formation'
      @auto_scaling_groups_mock      = mock 'auto scaling'
      @ec2_mock                      = mock 'ec2'
      @instance_reservation_set_mock = mock 'reservation'
      @instance_data_mock            = mock 'instance data mock'

      SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                        with(:logger => @logger_mock).
                                        and_return @cloud_formation_mock
    end

    context "with no ASGs" do
      before do
        @cloud_formation_mock.should_receive(:stack_resources).
                              with('stack').
                              and_return []
      end

      it "should return an empty array" do
        instance_reader = SimpleDeploy::InstanceReader.new :logger => @logger_mock
        instance_reader.list_stack_instances('stack').should == []
      end
    end

    context "with an ASG" do
      before do
        stack_resource_results = [{'StackName' => 'stack',
                                   'ResourceType' => 'AWS::AutoScaling::AutoScalingGroup',
                                   'PhysicalResourceId' => 'asg1'}]

        @cloud_formation_mock.should_receive(:stack_resources).
                              with('stack').
                              and_return stack_resource_results

        SimpleDeploy::AWS::AutoScalingGroups.should_receive(:new).
                                             with(:asg_id => "asg1").
                                             and_return @auto_scaling_groups_mock
      end

      context "with no running instances" do
        it "should return empty array" do
          @auto_scaling_groups_mock.should_receive(:list_instances).
                                    and_return []

          instance_reader = SimpleDeploy::InstanceReader.new :logger => @logger_mock
          instance_reader.list_stack_instances('stack').should == []
        end
      end

      context "with running instances" do
        it "should return the reservation set for each running instance" do
          @auto_scaling_groups_mock.should_receive(:list_instances).
                                    and_return ['instance1', 'instance2']

          @ec2_mock.should_receive(:describe_instance).
                    with(['instance1', 'instance2']).
                    and_return @instance_reservation_set_mock

          SimpleDeploy::AWS::EC2.should_receive(:new).
                                 and_return @ec2_mock
          instance_reader = SimpleDeploy::InstanceReader.new :logger => @logger_mock
          instance_reader.list_stack_instances('stack').should == @instance_reservation_set_mock
        end
      end
    end
  end
end
