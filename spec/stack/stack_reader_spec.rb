require 'spec_helper'

describe SimpleDeploy::StackReader do
  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    @config_stub = stub 'Config', :logger => @logger_stub, :access_key => 'key', :secret_key => 'XXX', :region => 'us-west1'

    @resource_manager = SimpleDeploy::ResourceManager.instance
    @resource_manager.should_receive(:config).and_return(@config_stub)

    @entry_mock = mock 'Entry'
    @entry_mock.stub(:attributes).and_return(:chef_repo_bucket_prefix => 'chef_repo_bp')
    SimpleDeploy::Entry.stub(:new).and_return(@entry_mock)

    @cf_mock = mock 'CloudFormation'
    SimpleDeploy::AWS::CloudFormation.stub(:new).and_return(@cf_mock)
    @cf_mock.stub(:stack_outputs).and_return([{'key' => 'value'}])
    @cf_mock.stub(:stack_status).and_return('green')
    @cf_mock.stub(:stack_events).and_return(['event1', 'event2'])
    @cf_mock.stub(:stack_resources).and_return([{'StackName' => 'my_stack'}])
    @cf_mock.stub(:template).and_return('{"Parameters": {"EIP": "string"}}')

    @instance_reader_mock = mock 'InstanceReader'
    SimpleDeploy::InstanceReader.stub(:new).and_return(@instance_reader_mock)
    @instance_reader_mock.stub(:list_stack_instances).and_return(['instance1', 'instance2'])

    @stack_reader = SimpleDeploy::StackReader.new(:name => 'my_stack', :logger => @logger_stub)
  end

  after do
    @resource_manager.release_config
  end

  describe 'attributes' do
    it 'should return the stack attributes' do
      @stack_reader.attributes.should == { :chef_repo_bucket_prefix => 'chef_repo_bp' }
    end
  end

  describe 'outputs' do
    it 'should return the stack outputs' do
      @stack_reader.outputs.should == [{'key' => 'value'}]
    end
  end

  describe 'status' do
    it 'should return the stack status' do
      @stack_reader.status.should == 'green'
    end
  end

  describe 'events' do
    it 'should return the stack events' do
      @stack_reader.events(2).should == ['event1', 'event2']
    end
  end

  describe 'resources' do
    it 'should return the stack resources' do
      @stack_reader.resources.should == [{'StackName' => 'my_stack'}]
    end
  end

  describe 'template' do
    it 'should return the stack template' do
      @stack_reader.template.should == '{"Parameters": {"EIP": "string"}}'
    end
  end

  describe 'parameters' do
    it 'should return the stack parameters' do
      @stack_reader.parameters.should == ['EIP']
    end
  end

  describe 'instances' do
    it 'should return the stack instances' do
      @stack_reader.instances.should == ['instance1', 'instance2']
    end
  end
end
