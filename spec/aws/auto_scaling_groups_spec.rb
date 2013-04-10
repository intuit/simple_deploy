require 'spec_helper'

describe SimpleDeploy::AWS::AutoScalingGroups do
  before do
    @config_stub = stub 'Config', :access_key => 'key',
                                  :secret_key => 'XXX',
                                  :region => 'us-west1'
    instances = ['first',{ 'Instances' => [{ 'InstanceId' => 'i-000001' },
                                           { 'InstanceId' => 'i-000002' }] }]
    body =  { 'DescribeAutoScalingGroupsResult' => { 'AutoScalingGroups' => instances } }
    @response_stub = stub 'Fog::Response', :body => body
    @auto_scaling_mock = mock 'AutoScalingGroups'

    SimpleDeploy.should_receive(:config).and_return(@config_stub)
    Fog::AWS::AutoScaling.stub :new => @auto_scaling_mock
    @auto_scaling_groups = SimpleDeploy::AWS::AutoScalingGroups.new :asg_id => 'asg_name'
  end

  describe 'list_instances' do
    it "should return the array of instance id's when passed the AutoScaleGroup name" do
      @auto_scaling_mock.should_receive(:describe_auto_scaling_groups).
                         with('AutoScalingGroupNames' => ['asg_name']).
                         and_return(@response_stub)

      @auto_scaling_groups.list_instances.should ==  ['i-000001','i-000002' ]


    end
  end
end
