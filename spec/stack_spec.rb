require 'spec_helper'

describe SimpleDeploy::Stack do
  include_context 'double stubbed config', :access_key => 'access',
                                           :secret_key => 'secret',
                                           :region     => 'us-west-1'
  include_context 'double stubbed logger'
        

  before do
    @environment_config_mock = mock 'environment config mock'

    @config_stub.stub(:environment).and_return(@environment_config_mock)
    @config_stub.stub(:artifacts).and_return(['chef_repo', 'cookbooks', 'app'])
    @config_stub.stub(:artifact_cloud_formation_url).and_return('CookBooksURL')

    @entry_mock = mock 'entry mock'
    SimpleDeploy::Entry.should_receive(:new).
                        at_least(:once).
                        with(:name   => 'test-stack').
                        and_return @entry_mock

    @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                     :environment => 'test-env'
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

      SimpleDeploy::StackCreator.should_receive(:new).
                                 with(:name          => 'test-stack',
                                      :entry         => @entry_mock,
                                      :template_file => 'some_json').
                                and_return @stack_creator_mock
      @stack_creator_mock.should_receive(:create)
        
      @stack.create :attributes => @new_attributes, :template => 'some_json'
    end
  end

  describe "updating a stack" do
    before do
      @stack_updater_mock = mock 'stack updater'
      @stack_reader_mock = mock 'stack reader'
      @new_attributes = [
        { 'chef_repo' => 'test123' },
        { 'chef_repo_bucket_prefix' => 'test-prefix' },
        { 'chef_repo_domain' => 'test-domain' }
      ]

      @expected_attributes = [
        { 'chef_repo' => 'test123' },
        { 'chef_repo_bucket_prefix' => 'test-prefix' },
        { 'chef_repo_domain' => 'test-domain' },
        { 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }
      ]
    end

    it "should update when the deployment is not locked" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => true
      @stack.stub(:deployment).and_return(deployment_stub)

      @entry_mock.should_receive(:set_attributes).with(@expected_attributes)
      @entry_mock.should_receive(:save).and_return(true)

      SimpleDeploy::StackUpdater.should_receive(:new).
                                 with(:name          => 'test-stack',
                                      :entry         => @entry_mock,
                                      :template_body => 'some_json').
                                 and_return @stack_updater_mock
      @stack_updater_mock.stub(:update_stack).and_return(true)
      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:attributes).and_return({})
      @stack_reader_mock.should_receive(:template).and_return('some_json')

      @stack.update(:attributes => @new_attributes).should be_true
    end

    it "should not update when the deployment is locked and force is not set" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormatter.should_not_receive(:new)

      @stack.update(:attributes => { 'arg1' => 'val' }).should_not be_true
    end

    it "should update when the deployment is locked and force is set true" do
      deployment_mock = mock 'deployment'
      deployment_mock.should_receive(:clear_for_deployment?).and_return(false, true, true)
      deployment_mock.should_receive(:clear_deployment_lock).with(true)
      @stack.stub(:deployment).and_return(deployment_mock)
      @stack.stub(:sleep).and_return(false)

      @entry_mock.should_receive(:set_attributes).with(@expected_attributes)
      @entry_mock.should_receive(:save).and_return(true)

      SimpleDeploy::StackUpdater.should_receive(:new).
                                 with(:name          => 'test-stack',
                                      :entry         => @entry_mock,
                                      :template_body => 'some_json').
                                 and_return @stack_updater_mock
      @stack_updater_mock.stub(:update_stack).and_return(true)
      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:attributes).and_return({})
      @stack_reader_mock.should_receive(:template).and_return('some_json')

      @stack.update(:force => true, :attributes => @new_attributes).should be_true
    end

    it "should not update when the deployment is locked and force is set false" do
      deployment_stub = stub 'deployment', :clear_for_deployment? => false
      @stack.stub(:deployment).and_return(deployment_stub)

      SimpleDeploy::StackAttributeFormatter.should_not_receive(:new)

      @stack.update(:force => false, :attributes => { 'arg1' => 'val' }).should_not be_true
    end
  end

  describe "destroying a stack" do
    before do
      @stack_reader_mock = mock 'stack reader'
      @stack_destroyer_mock = mock 'stack destroyer'
    end

    it "should destroy if the stack is not protected" do
      @entry_mock.should_receive(:delete_attributes)

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:attributes).and_return('protection' => 'off')
      SimpleDeploy::StackDestroyer.should_receive(:new).
                                   with(:name   => 'test-stack').
                                   and_return @stack_destroyer_mock
      @stack_destroyer_mock.should_receive(:destroy).and_return(true)

      @stack.destroy.should be_true
    end

    it "should not destroy if the stack is protected" do
      @entry_mock.should_receive(:delete_attributes).never

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:attributes).and_return('protection' => 'on')
      SimpleDeploy::StackDestroyer.should_receive(:new).never

      @stack.destroy.should_not be_true
    end

    it "should destroy if protection is undefined" do
      @entry_mock.should_receive(:delete_attributes)

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:attributes).and_return({})
      SimpleDeploy::StackDestroyer.should_receive(:new).
                                   with(:name   => 'test-stack').
                                   and_return @stack_destroyer_mock
      @stack_destroyer_mock.should_receive(:destroy).and_return(true)

      @stack.destroy.should be_true
    end
  end

  describe 'instances' do
    before do
      @stack_reader_mock = mock 'stack reader'

      @instances = [
        { 'instancesSet' => [{ 'ipAddress' => '50.40.30.20',
                               'privateIpAddress' => '10.1.2.3' }] }
      ]
    end

    it 'should use the private IP when vpc' do
      @instances.first['instancesSet'].first['vpcId'] = 'my-vpc'

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:instances).and_return(@instances)

      @stack.instances.should == ['10.1.2.3']
    end

    it 'should use the private IP when internal' do
      stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                      :environment => 'test-env',
                                      :internal    => true

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:instances).and_return(@instances)

      stack.instances.should == ['10.1.2.3']
    end

    it 'should use the public IP when not vpc and not internal' do
      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:instances).and_return(@instances)

      @stack.instances.should == ['50.40.30.20']
    end

    it 'should handle instanceSets with multiple intances' do
      @instances = [{ 'instancesSet' => [
        { 'ipAddress' => '50.40.30.20', 'privateIpAddress' => '10.1.2.3' },
        { 'ipAddress' => '50.40.30.21', 'privateIpAddress' => '10.1.2.4' }] }]

      SimpleDeploy::StackReader.should_receive(:new).
                                 with(:name   => 'test-stack').
                                 and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:instances).and_return(@instances)

      @stack.instances.should == ['50.40.30.20', '50.40.30.21']
    end
  end

  describe 'deploy' do
    before do
      @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :config      => @config_stub,
                                       :internal    => false
      @deployment_mock = mock "deployment"
      @stack.stub(:deployment).and_return(@deployment_mock)
    end

    it "should call exec on deployment" do
      @deployment_mock.should_receive(:execute).with(true).and_return true
      @stack.deploy(true).should be_true
    end

    it "should not force the deployment by default" do
      @deployment_mock.should_receive(:execute).with(false).and_return true
      @stack.deploy.should be_true
    end

    it "should return false if the deployment fails" do
      @deployment_mock.should_receive(:execute).with(false).and_return false
      @stack.deploy.should be_false
    end
  end

  describe 'execute' do
    before do
      @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :config      => @config_stub,
                                       :internal    => false
      @execute_mock = mock "execute"
      @stack.stub(:executer).and_return(@execute_mock)
    end

    it "should call exec with the given args" do
      @execute_mock.should_receive(:execute).
                    with(:arg => 'val').and_return true
      @stack.execute(:arg => 'val').should be_true
    end

    it "should return false if the exec fails" do
      @execute_mock.should_receive(:execute).
                    with(:arg => 'val').and_return false
      @stack.execute(:arg => 'val').should be_false
    end
  end

  describe "wait_for_stable" do
    before do
      @status_mock = mock 'status'
      @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                       :config      => @config_stub,
                                       :internal    => false
    end

    it "should call wait_for_stable on status" do
      SimpleDeploy::Status.should_receive(:new).
                           with(:name   => 'test-stack').
                           and_return @status_mock
      @status_mock.should_receive(:wait_for_stable)

      @stack.wait_for_stable
    end
  end

  describe "exists?" do
    before do
      @stack_reader_mock = mock 'stack reader'
      @stack = SimpleDeploy::Stack.new :name        => 'test-stack',
                                       :config      => @config_stub,
                                       :internal    => false
    end

    it "should return true if stack exists" do
      SimpleDeploy::StackReader.should_receive(:new).
                                with(:name   => 'test-stack').
                                and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:status).and_return('CREATE_COMPLETE')

      @stack.exists?.should be_true
    end

    it "should return false if the stack does not exist" do
      SimpleDeploy::StackReader.should_receive(:new).
                                with(:name   => 'test-stack').
                                and_return @stack_reader_mock
      @stack_reader_mock.should_receive(:status).
                         and_raise(SimpleDeploy::Exceptions::UnknownStack.new(
                                  'Stack:test-stack does not exist'))

      @stack.exists?.should be_false
    end
  end
end
