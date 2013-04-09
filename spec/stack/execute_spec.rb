require 'spec_helper'

describe SimpleDeploy::Stack::Execute do
  before do
    @ssh_mock = mock 'ssh'
    @config_mock = mock 'config'
    @logger_mock = mock 'logger', :info => true

    options = { :logger      => @logger_mock,
                :instances   => @instances,
                :environment => @environment,
                :ssh_user    => @ssh_user,
                :ssh_key     => @ssh_key,
                :stack       => @stack,
                :name        => @name }

    @resource_manager = SimpleDeploy::ResourceManager.instance
    @resource_manager.should_receive(:config).and_return(@config_mock)

    SimpleDeploy::Stack::SSH.should_receive(:new).
                             with(options).
                             and_return @ssh_mock
    @execute = SimpleDeploy::Stack::Execute.new options
  end

  after do
    @resource_manager.release_config
  end

  it "should call execute with the given options" do
    options = { :sudo => true, :command => 'uname' }
    @ssh_mock.should_receive(:execute).
              with(options).
              and_return true
    @execute.execute(options).should be_true
  end
end
