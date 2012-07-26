require 'spec_helper'

describe SimpleDeploy do

  before do
    @attributes = { 'key' => 'val' }
    @config_mock = mock 'config mock'
    @stack_mock = mock 'stack mock'

    @stack_mock.should_receive(:attributes).and_return @attributes
    @config_mock.should_receive(:logger).and_return @logger_mock
    @config_mock.should_receive(:region).with('test-us-west-1').
                                         and_return 'us-west-1'

    options = { :config      => @config_mock,
                :instances   => ['1.2.3.4', '4.3.2.1'],
                :environment => 'test-us-west-1',
                :ssh_user    => 'user',
                :ssh_key     => 'key',
                :stack       => @stack_mock,
                :name        => 'stack-name' }
    @stack = SimpleDeploy::Stack::Deployment.new options
  end

  it "should not blow up creating a new deployment" do
    @stack.class.should == SimpleDeploy::Stack::Deployment
  end

  it "should deploy if the stack is clear to deploy"
  it "should deploy if the stack is not clear to deploy but forced"
  it "should deploy if the stack is not clear to deploy but forced"

end
