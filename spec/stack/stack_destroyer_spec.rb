require 'spec_helper'

describe SimpleDeploy::StackDestroyer do
  include_context 'stubbed config'
  include_context 'double stubbed logger'

  it "should destroy the stack" do
    cloud_formation_mock = mock 'cloud formation mock'

    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      and_return cloud_formation_mock
    cloud_formation_mock.should_receive(:destroy).with 'test-stack'
                         
    stack_destroyer = SimpleDeploy::StackDestroyer.new :name   => 'test-stack'
    stack_destroyer.destroy
  end

end
