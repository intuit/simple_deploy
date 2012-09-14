require 'spec_helper'

describe SimpleDeploy do

  before do
    @config_mock = mock 'config mock'
    @logger_stub = stub 'logger stub', :info => ''
    @config_mock.should_receive(:logger).and_return @logger_stub
    SimpleDeploy::Config.should_receive(:new).
                         with(:logger => 'my-logger').
                         and_return @config_mock
    @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                     :name        => 'test-stack',
                                     :logger      => 'my-logger',
                                     :config      => @config_mock
  end

  describe "A stack" do
    it "should call create stack" do
      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      environment_config_mock = mock 'environment config mock'
      @config_mock.should_receive(:environment).with('test-env').
                   and_return environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env').
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:create).with :attributes => { 'arg1' => 'new_val' },
                                              :template   => 'some_json'
      @stack.create(:attributes => { 'arg1' => 'val' }, 
                    :template => 'some_json')
    end

    it "should call update stack" do
      deployment_stub = stub 'deployment', :cleared_to_deploy? => true
      @stack.should_receive(:deployment).and_return(deployment_stub)

      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      environment_config_mock = mock 'environment config mock'
      @config_mock.should_receive(:environment).with('test-env').
                   and_return environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env').
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:update).with :attributes => { 'arg1' => 'new_val' }
      @stack.update false, :attributes => { 'arg1' => 'val' }
    end

  end

  describe "updating a stack" do
    it "should update when the deployment is not locked" do
      deployment_stub = stub 'deployment', :cleared_to_deploy? => true
      @stack.should_receive(:deployment).and_return(deployment_stub)

      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      environment_config_mock = mock 'environment config mock'
      @config_mock.should_receive(:environment).with('test-env').
                   and_return environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env').
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:update).with :attributes => { 'arg1' => 'new_val' }
      @stack.update false, :attributes => { 'arg1' => 'val' }
    end

    it "should not update when the deployment is locked" do
      deployment_stub = stub 'deployment', :cleared_to_deploy? => false
      @stack.should_receive(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_receive(:new).never
      Stackster::Stack.should_receive(:new).never

      @stack.update false, :attributes => { 'arg1' => 'val' }
    end
  end

  describe "destroying a stack" do
    it "should not create a deployment" do
      @stack.should_receive(:deployment).never

      stack_mock = mock 'stackster stack mock'
      @stack.should_receive(:stack).and_return(stack_mock)
      stack_mock.should_receive(:destroy)

      @stack.destroy
    end
  end
end
