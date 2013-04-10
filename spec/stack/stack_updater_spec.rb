require 'spec_helper'
require 'json'

describe SimpleDeploy::StackUpdater do

  before do
    @template_body = '{ "Parameters": 
                        { 
                          "param1" : 
                            {
                              "Description" : "param-1"
                            },
                          "param2" : 
                            {
                              "Description" : "param-2"
                            }
                        }
                      }'
  end

  it "should update the stack when parameters change and stack is stable" do
    attributes = { "param1" => "value1", "param3" => "value3" }
    config_mock = mock 'config mock'
    logger_mock = mock 'logger mock'
    entry_mock = mock 'entry mock'
    status_mock = mock 'status mock'
    cloud_formation_mock = mock 'cloud formation mock'
    SimpleDeploy.stub(:config).and_return(config_mock)
    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      with(:logger => logger_mock).
                                      and_return cloud_formation_mock
    entry_mock.should_receive(:attributes).and_return attributes
    cloud_formation_mock.should_receive(:update).
                         with(:name      => 'test-stack', 
                              :parameters => { 'param1' => 'value1' },
                              :template   => @template_body).
                         and_return true
    logger_mock.should_receive(:debug).exactly(1).times
    logger_mock.should_receive(:info).exactly(1).times
    SimpleDeploy::Status.should_receive(:new).
                      with(:name   => 'test-stack',
                           :logger => logger_mock).
                      and_return status_mock
    status_mock.should_receive(:wait_for_stable).and_return true
    stack_updater = SimpleDeploy::StackUpdater.new :name          => 'test-stack',
                                                   :template_body => @template_body,
                                                   :entry         => entry_mock,
                                                   :logger        => logger_mock

    stack_updater.update_stack_if_parameters_changed( [ { 'param1' => 'new-value' } ] ).
                  should == true
  end

  it "should raise an error when parameters change and stack is not stable" do
    attributes = { "param1" => "value1", "param3" => "value3" }
    config_mock = mock 'config mock'
    logger_mock = mock 'logger mock'
    entry_mock = mock 'entry mock'
    status_mock = mock 'status mock'
    cloud_formation_mock = mock 'cloud formation mock'
    SimpleDeploy.stub(:config).and_return(config_mock)
    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      exactly(0).times
    logger_mock.should_receive(:debug).exactly(1).times
    SimpleDeploy::Status.should_receive(:new).
                         with(:name   => 'test-stack',
                              :logger => logger_mock).
                         and_return status_mock
    status_mock.should_receive(:wait_for_stable).and_return false
    stack_updater = SimpleDeploy::StackUpdater.new :name          => 'test-stack',
                                                   :template_body => @template_body,
                                                   :entry         => entry_mock,
                                                   :logger        => logger_mock

    lambda {stack_updater.update_stack_if_parameters_changed( [ { 'param1' => 'new-value' } ] ) }.
                  should raise_error
  end

  it "should not update the stack when parameters don't change" do
    attributes = { "param3" => "value3" }
    config_mock = mock 'config mock'
    logger_mock = mock 'logger mock'
    entry_mock = mock 'entry mock'
    SimpleDeploy.stub(:config).and_return(config_mock)
    SimpleDeploy::AWS::CloudFormation.should_receive(:new).exactly(0).times
    logger_mock.should_receive(:debug).with("No Cloud Formation parameters require updating.")
    stack_updater = SimpleDeploy::StackUpdater.new :name          => 'test-stack',
                                                   :template_body => @template_body,
                                                   :entry         => entry_mock,
                                                   :logger        => logger_mock

    stack_updater.update_stack_if_parameters_changed( [ { 'another-param' => 'new-value' } ] ).
                  should == false
  end

end
