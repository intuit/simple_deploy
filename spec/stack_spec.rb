require 'spec_helper'

describe SimpleDeploy do

  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    @environment_config_mock = mock 'environment config mock'

    @config_stub = stub 'config stub', :region => 'us-west-1', :logger => @logger_stub
    @config_stub.stub(:environment).and_return(@environment_config_mock)
    @config_stub.stub(:artifacts).and_return(['chef_repo', 'cookbooks', 'app'])
    @config_stub.stub(:artifact_cloud_formation_url).and_return('CookBooksURL')

    SimpleDeploy::Config.should_receive(:new).
                         at_least(:once).
                         with(:logger => 'my-logger').
                         and_return @config_stub
    @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                     :name        => 'test-stack',
                                     :logger      => 'my-logger',
                                     :config      => @config_stub

    @main_attributes = {
      'chef_repo_bucket_prefix' => 'test-prefix',
      'chef_repo_domain' => 'test-domain' 
    }

    @stack_mock = mock 'stackster stack'

    @expected_attributes = [
      { 'chef_repo' => 'test123' },
      { 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }
    ]
  end

  describe "creating a stack" do
    before do
      @stack_mock.stub(:attributes).and_return({})
    end

    it "should set the attributes using what is passed to the create command" do
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return @stack_mock

      expecteds = [
        { 'chef_repo' => 'test123' },
        { 'chef_repo_bucket_prefix' => 'test-prefix' },
        { 'chef_repo_domain' => 'test-domain' },
        { 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }
      ]
      @stack_mock.should_receive(:create).with :attributes => expecteds,
                                               :template   => 'some_json'

      attributes = [
        { 'chef_repo' => 'test123' },
        { 'chef_repo_bucket_prefix' => 'test-prefix' },
        { 'chef_repo_domain' => 'test-domain' }
      ]

      @stack.create :attributes => attributes, :template => 'some_json'
    end
  end

  describe "updating a stack" do
    before do
      @stack_mock.stub(:attributes).and_return(@main_attributes)
    end

    it "should update when the deployment is not locked" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => true
      @stack.stub(:deployment).and_return(deployment_stub)

      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return @stack_mock
      @stack_mock.should_receive(:update).with :attributes => @expected_attributes

      @stack.update(:attributes => [{ 'chef_repo' => 'test123' }]).should be_true
    end

    it "should not update when the deployment is locked and force is not set" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update(:attributes => { 'arg1' => 'val' }).should_not be_true
    end

    it "should update when the deployment is locked and force is set true" do
      deployment_mock = mock 'deployment'
      deployment_mock.should_receive(:clear_for_deployment?).and_return(false, true, true)
      deployment_mock.should_receive(:clear_deployment_lock).with(true)
      @stack.stub(:deployment).and_return(deployment_mock)

      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return @stack_mock
      @stack_mock.should_receive(:update).with :attributes => @expected_attributes

      @stack.update(:force => true, :attributes => [{ 'chef_repo' => 'test123' }]).should be_true
    end

    it "should not update when the deployment is locked and force is set false" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update(:force => false, :attributes => { 'arg1' => 'val' }).should_not be_true
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

  describe 'instances' do
    before do
      @instances = [{ 'instancesSet' => [{ 'ipAddress' => '50.40.30.20', 'privateIpAddress' => '10.1.2.3' }] }]
      @environment_config_mock.stub(:[])
    end

    it 'should use the private IP when vpc' do
      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      stack.stub(:stack) { @stack_mock }

      @instances.first['instancesSet'].first['vpcId'] = 'my-vpc'
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['10.1.2.3']
    end

    it 'should use the private IP when internal' do
      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => true
      stack.stub(:stack) { @stack_mock }
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['10.1.2.3']
    end

    it 'should use the public IP when not vpc and not internal' do
      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      stack.stub(:stack) { @stack_mock }
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['50.40.30.20']
    end

    it 'should handle instanceSets with multiple intances' do
      @instances = [{ 'instancesSet' => [
        { 'ipAddress' => '50.40.30.20', 'privateIpAddress' => '10.1.2.3' },
        { 'ipAddress' => '50.40.30.21', 'privateIpAddress' => '10.1.2.4' }] }]

      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      stack.stub(:stack) { @stack_mock }
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['50.40.30.20', '50.40.30.21']
    end
  end
end
