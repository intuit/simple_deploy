require 'spec_helper'

describe SimpleDeploy do

  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    
    @environment_config_mock = mock 'environment config mock'
    @config_mock = mock 'config mock'
    @config_mock.should_receive(:logger).and_return @logger_stub
    @config_mock.stub(:environment).and_return(@environment_config_mock)

    SimpleDeploy::Config.should_receive(:new).
                         with(:logger => 'my-logger').
                         and_return @config_mock
    @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                     :name        => 'test-stack',
                                     :logger      => 'my-logger',
                                     :config      => @config_mock

    @main_attributes = { 'arg1_bucket_prefix' => 'arg1_bp' }
  end

  describe "A stack" do
    it "should call create stack" do
      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      stack_mock.stub(:attributes).and_return(@main_attributes)
      @config_mock.should_receive(:environment).with('test-env').
                   and_return @environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env',
                                                :main_attributes => @main_attributes).
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
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
      deployment_stub = stub 'deployment', :clear_for_deployment? => true
      @stack.stub(:deployment).and_return(deployment_stub)

      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      stack_mock.stub(:attributes).and_return(@main_attributes)
      @config_mock.should_receive(:environment).with('test-env').
                   and_return @environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env',
                                                :main_attributes => @main_attributes).
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:update).with :attributes => { 'arg1' => 'new_val' }
      @stack.update :attributes => { 'arg1' => 'val' }
    end

  end

  describe "updating a stack" do
    it "should update when the deployment is not locked" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => true
      @stack.stub(:deployment).and_return(deployment_stub)

      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      stack_mock.stub(:attributes).and_return(@main_attributes)
      @config_mock.should_receive(:environment).with('test-env').
                   and_return @environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env',
                                                :main_attributes => @main_attributes).
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:update).with :attributes => { 'arg1' => 'new_val' }
      @stack.update :attributes => { 'arg1' => 'val' }
    end

    it "should not update when the deployment is locked and force is not set" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update :attributes => { 'arg1' => 'val' }
    end

    it "should update when the deployment is locked and force is set true" do
      deployment_mock = mock 'deployment'
      deployment_mock.should_receive(:clear_for_deployment?).and_return(false, true)
      deployment_mock.should_receive(:clear_deployment_lock).with(true)
      @stack.stub(:deployment).and_return(deployment_mock)

      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      stack_mock.stub(:attributes).and_return(@main_attributes)
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env',
                                                :main_attributes => @main_attributes).
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:update).with :attributes => { 'arg1' => 'new_val' }
      @stack.update :force => true, :attributes => { 'arg1' => 'val' }
    end

    it "should not update when the deployment is locked and force is set false" do
      deployment_mock = mock 'deployment'
      deployment_mock.should_receive(:clear_for_deployment?).and_return(false, false)
      @stack.stub(:deployment).and_return(deployment_mock)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update :force => false, :attributes => { 'arg1' => 'val' }
    end
  end

  describe "destroying a stack" do
    it "should destroy if the stack is not protected" do
      stack_mock = mock 'stackster stack mock', :attributes => { 'protection' => 'off' }
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_receive(:destroy)

      @stack.destroy.should be_true
    end

    it "should not destroy if the stack is protected" do
      stack_mock = mock 'stackster stack mock', :attributes => { 'protection' => 'on' }
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_not_receive(:destroy)

      @stack.destroy.should_not be_true
    end

    it "should destroy if protection is undefined" do
      stack_mock = mock 'stackster stack mock', :attributes => {}
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_receive(:destroy)

      @stack.destroy.should be_true
    end

    it "should not create a deployment" do
      @stack.should_not_receive(:deployment)

      stack_mock = mock 'stackster stack mock', :attributes => { 'protection' => 'off' }
      @stack.stub(:stack) { stack_mock }
      stack_mock.should_receive(:destroy)

      @stack.destroy.should be_true
    end
  end
end
