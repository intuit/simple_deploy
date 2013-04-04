require 'spec_helper'

describe SimpleDeploy::StackDestroyer do

  it "should destroy the stack" do
    config_mock = mock 'config mock'
    cloud_formation_mock = mock 'cloud formation mock'
    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      with(:config => config_mock).
                                      and_return cloud_formation_mock
    cloud_formation_mock.should_receive(:destroy).with 'test-stack'
                         
    stack_destroyer = SimpleDeploy::StackDestroyer.new :name   => 'test-stack',
                                                       :config => config_mock
    stack_destroyer.destroy
  end

end
