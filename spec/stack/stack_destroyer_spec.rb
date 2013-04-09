require 'spec_helper'

describe SimpleDeploy::StackDestroyer do

  it "should destroy the stack" do
    config_mock = mock 'config mock'
    logger_stub = mock 'logger stub', :info => true
    cloud_formation_mock = mock 'cloud formation mock'
    resource_manager = SimpleDeploy::ResourceManager.instance
    resource_manager.should_receive(:config).and_return(config_mock)

    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      with(:logger => logger_stub).
                                      and_return cloud_formation_mock
    cloud_formation_mock.should_receive(:destroy).with 'test-stack'
                         
    stack_destroyer = SimpleDeploy::StackDestroyer.new :name   => 'test-stack',
                                                       :logger => logger_stub
    stack_destroyer.destroy
  end

end
