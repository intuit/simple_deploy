require 'spec_helper'

describe SimpleDeploy do

  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    @environment_config_mock = mock 'environment config mock'

    @config_stub = stub 'config stub', :region => 'us-west-1', :logger => @logger_stub
    @config_stub.stub(:environment).and_return(@environment_config_mock)
    @config_stub.stub(:artifacts).and_return(['chef_repo', 'cookbooks', 'app'])
    @config_stub.stub(:artifact_cloud_formation_url).and_return('CookBooksURL')
    @config_stub.stub(:access_key).and_return('access')
    @config_stub.stub(:secret_key).and_return('secret')
    SimpleDeploy::Config.should_receive(:new).
                         once.
                         with(:logger => @logger_stub).
                         and_return @config_stub

    @entry_mock = mock 'entry mock'
    SimpleDeploy::Entry.should_receive(:new).
                        at_least(:once).
                        with(:name => 'test-stack',
                             :config => @config_stub).
                        and_return @entry_mock

    @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                     :logger      => @logger_stub,
                                     :environment => 'test-env'

    @main_attributes = {
      'chef_repo_bucket_prefix' => 'test-prefix',
      'chef_repo_domain' => 'test-domain' 
    }

    @stack_mock = mock 'stack'

    @expected_attributes = [
      { 'chef_repo' => 'test123' },
      { 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }
    ]
  end

  describe "creating a stack" do
    before do
      @stack_creator_mock = mock 'stack creator'
      @new_attributes = [
        { 'chef_repo' => 'test123' },
        { 'chef_repo_bucket_prefix' => 'test-prefix' },
        { 'chef_repo_domain' => 'test-domain' }
      ]

      @expected_attributes = @new_attributes +
        [{ 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }]
    end

    it "should set the attributes using what is passed to the create command" do
      @entry_mock.should_receive(:attributes).and_return({})
      @entry_mock.should_receive(:set_attributes).with(@expected_attributes)
      @entry_mock.should_receive(:save).and_return(true)

      SimpleDeploy::Stack::StackCreator.should_receive(:new).
                                 with(:name          => 'test-stack',
                                      :entry         => @entry_mock,
                                      :template_file => 'some_json',
                                      :config        => @config_stub).
                                and_return @stack_creator_mock
      @stack_creator_mock.should_receive(:create)
        
      @stack.create :attributes => @new_attributes, :template => 'some_json'
    end

    it "should raise CloudFormationError if the create fails" do
      @entry_mock.should_receive(:attributes).and_return({})
      @entry_mock.should_receive(:set_attributes).with(@expected_attributes)
      @entry_mock.should_receive(:save).never

      SimpleDeploy::Stack::StackCreator.should_receive(:new).
                                 with(:name          => 'test-stack',
                                      :entry         => @entry_mock,
                                      :template_file => 'some_json',
                                      :config        => @config_stub).
                                and_return @stack_creator_mock
      @stack_creator_mock.should_receive(:create).
                          and_raise(Exception.new('cf failure'))

      expect {
        @stack.create :attributes => @new_attributes, :template => 'some_json'
      }.to raise_error(SimpleDeploy::Exceptions::CloudFormationError, 'cf failure')
    end
  end

  describe "updating a stack" do
    before do
      @stack_mock.stub(:attributes).and_return(@main_attributes)
    end

    pending "should update when the deployment is not locked" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => true
      @stack.stub(:deployment).and_return(deployment_stub)

      Stackster::Stack.should_receive(:new).with(:name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return @stack_mock
      @stack_mock.should_receive(:update).with :attributes => @expected_attributes

      @stack.update(:attributes => [{ 'chef_repo' => 'test123' }]).should be_true
    end

    pending "should not update when the deployment is locked and force is not set" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update(:attributes => { 'arg1' => 'val' }).should_not be_true
    end

    pending "should update when the deployment is locked and force is set true" do
      deployment_mock = mock 'deployment'
      deployment_mock.should_receive(:clear_for_deployment?).and_return(false, true, true)
      deployment_mock.should_receive(:clear_deployment_lock).with(true)
      @stack.stub(:deployment).and_return(deployment_mock)
      @stack.stub(:sleep).and_return(false)

      Stackster::Stack.should_receive(:new).with(:name        => 'test-stack',
                                                 :config      => @environment_config_mock,
                                                 :logger      => @logger_stub).
                                            and_return @stack_mock
      @stack_mock.should_receive(:update).with :attributes => @expected_attributes

      @stack.update(:force => true, :attributes => [{ 'chef_repo' => 'test123' }]).should be_true
    end

    pending "should not update when the deployment is locked and force is set false" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormater.should_not_receive(:new)
      Stackster::Stack.should_not_receive(:new)

      @stack.update(:force => false, :attributes => { 'arg1' => 'val' }).should_not be_true
    end
  end

  describe "destroying a stack" do
    pending "should destroy if the stack is not protected" do
      stack_mock = mock 'stackster stack mock', :attributes => { 'protection' => 'off' }
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_receive(:destroy)

      @stack.destroy.should be_true
    end

    pending "should not destroy if the stack is protected" do
      stack_mock = mock 'stackster stack mock', :attributes => { 'protection' => 'on' }
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_not_receive(:destroy)

      @stack.destroy.should_not be_true
    end

    pending "should destroy if protection is undefined" do
      stack_mock = mock 'stackster stack mock', :attributes => {}
      @stack.stub(:stack) { stack_mock }

      stack_mock.should_receive(:destroy)

      @stack.destroy.should be_true
    end

    pending "should not create a deployment" do
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

    pending 'should use the private IP when vpc' do
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

    pending 'should use the private IP when internal' do
      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                      :name        => 'test-stack',
                                      :logger      => 'my-logger',
                                      :config      => @config_stub,
                                      :internal    => true
      stack.stub(:stack) { @stack_mock }
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['10.1.2.3']
    end

    pending 'should use the public IP when not vpc and not internal' do
      stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                      :name        => 'test-stack',
                                      :logger      => 'my-logger',
                                      :config      => @config_stub,
                                      :internal    => false
      stack.stub(:stack) { @stack_mock }
      @stack_mock.stub(:instances).and_return(@instances)

      stack.instances.should == ['50.40.30.20']
    end

    pending 'should handle instanceSets with multiple intances' do
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

  describe 'deploy' do
    before do
      @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      @deployment_mock = mock "deployment"
      @stack.stub(:deployment).and_return(@deployment_mock)
    end

    pending "should call exec on deployment" do
      @deployment_mock.should_receive(:execute).with(true).and_return true
      @stack.deploy(true).should be_true
    end

    pending "should not force the deployment by default" do
      @deployment_mock.should_receive(:execute).with(false).and_return true
      @stack.deploy.should be_true
    end

    pending "should return false if the deployment fails" do
      @deployment_mock.should_receive(:execute).with(false).and_return false
      @stack.deploy.should be_false
    end
  end

  describe 'execute' do
    before do
      @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      @execute_mock = mock "execute"
      @stack.stub(:executer).and_return(@execute_mock)
    end

    pending "should call exec with the given args" do
      @execute_mock.should_receive(:execute).
                    with(:arg => 'val').and_return true
      @stack.execute(:arg => 'val').should be_true
    end

    pending "should return false if the exec fails" do
      @execute_mock.should_receive(:execute).
                    with(:arg => 'val').and_return false
      @stack.execute(:arg => 'val').should be_false
    end
  end

  describe "wait_for_stable" do
    before do
      @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      @stack_mock.stub(:attributes).and_return({})
      Stackster::Stack.should_receive(:new).
                       with(:name        => 'test-stack',
                            :config      => @environment_config_mock,
                            :logger      => @logger_stub).
                       and_return @stack_mock
    end

    pending "should call wait_for_stable on stackster stack" do
      @stack_mock.should_receive(:wait_for_stable)
      @stack.wait_for_stable
    end
  end

  describe "exists?" do
    before do
      @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_stub,
                                       :internal    => false
      @stack_mock.stub(:attributes).and_return({})
      Stackster::Stack.should_receive(:new).
                       with(:name        => 'test-stack',
                            :config      => @environment_config_mock,
                            :logger      => @logger_stub).
                       and_return @stack_mock
    end

    pending "should return true if stack exists" do
      @stack_mock.stub :status => 'CREATE_COMPLTE'
      @stack.exists?.should be_true
    end

    pending "should return false if the stack does not exist" do
      @stack_mock.should_receive(:status).
                  and_raise Stackster::Exceptions::UnknownStack.new 'Stack:test-stack does not exist'
      @stack.exists?.should be_false
    end
  end
end
