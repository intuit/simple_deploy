require 'spec_helper'

describe SimpleDeploy::AWS::EC2 do
  include_context 'double stubbed config', :access_key => 'key',
                                           :secret_key => 'XXX',
                                           :region     => 'us-west-1'

  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true', :error => 'true'
    @instance_id = 'i-123456'
    @response_stub = stub 'Excon::Response', :body => {
      'reservationSet' => [{
        'instanceSet' => [{'instanceState' => {'name' => 'running'}},
                          {'ipAddress' => '54.10.10.1'},
                          {'instanceId' => 'i-123456'},
                          {'privateIpAddress' => '192.168.1.1'}]}]
    }

    @cf_mock = mock 'CloudFormation'
    Fog::Compute::AWS.stub(:new).and_return(@cf_mock)

    @ec2 = SimpleDeploy::AWS::EC2.new
  end

  describe 'describe_instance' do
    it 'should return the Cloud Formation description of only the running passed instance' do
      @cf_mock.should_receive(:describe_instances).and_return(@response_stub)

      @ec2.describe_instance(@instance_id).should == [{
       'instanceSet' => [{'instanceState' => {'name' => 'running'}},
                         {'ipAddress' => '54.10.10.1'},
                         {'instanceId' => 'i-123456'},
                         {'privateIpAddress' => '192.168.1.1'}]}]
    end
  end
end
