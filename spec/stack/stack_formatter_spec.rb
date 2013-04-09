require 'spec_helper'

describe ::SimpleDeploy::StackFormatter do
  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    @config_stub = stub 'Config', :logger => @logger_stub,
                                  :access_key => 'key',
                                  :secret_key => 'XXX',
                                  :region => 'us-west1'
    @resource_manager = SimpleDeploy::ResourceManager.instance
    @resource_manager.should_receive(:config).and_return(@config_stub)

    @stack_reader_mock = mock 'StackReader'
    SimpleDeploy::StackReader.stub(:new).and_return(@stack_reader_mock)
    @stack_reader_mock.stub(:attributes).and_return(:chef_repo_bucket_prefix => 'chef_repo_bp')
    @stack_reader_mock.stub(:outputs).and_return([{'key' => 'value'}])
    @stack_reader_mock.stub(:status).and_return('green')
    @stack_reader_mock.stub(:events).and_return(['event1', 'event2', 'event3'])
    @stack_reader_mock.stub(:resources).and_return([{'StackName' => 'my_stack'}])

    @stack_formatter = SimpleDeploy::StackFormatter.new(:name => 'my_stack')
  end

  after do
    @resource_manager.release_config
  end

  describe 'display' do
    it 'should return formatted information for the stack' do
      @stack_formatter.display.should == {
        'attributes' => { :chef_repo_bucket_prefix => 'chef_repo_bp' },
        'status' => 'green',
        'outputs' => [{'key' => 'value'}],
        'events' => ['event1', 'event2', 'event3'],
        'resources' => [{'StackName' => 'my_stack'}]
      }
    end
  end
end
