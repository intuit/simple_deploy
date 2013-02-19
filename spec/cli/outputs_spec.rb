require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Outputs do

  before do
    @config_object = mock 'config'
    @config_env    = mock 'environment config'
    @stack         = mock 'stack'
    @logger        = stub 'logger'
    @options       = { :environment => 'test',
                       :log_level   => 'info',
                       :name        => 'mytest' }
    @data          = [{ 'OutputKey' => 'key1', 'OutputValue' => 'value1' },
                      { 'OutputKey' => 'key2', 'OutputValue' => 'value2' }]
    Trollop.stub :options => @options
    @config_object.stub(:environments => { 'test' => 'data' })
    SimpleDeploy::Config.stub :new => @config_object
    SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                     with(:log_level => 'info').
                                     and_return @logger
    SimpleDeploy::Stack.should_receive(:new).
                        with(:environment => 'test',
                             :name        => 'mytest',
                             :config      => @config_env,
                             :logger      => @logger).
                        and_return(@stack)
    @stack.stub :outputs => @data
    @config_object.should_receive(:environment).with('test').
                                                and_return @config_env
    @outputs = SimpleDeploy::CLI::Outputs.new
  end

  it "should successfully return the show command with default values" do
    @outputs.should_receive(:puts).with('key1: value1')
    @outputs.should_receive(:puts).with('key2: value2')
    @outputs.show
  end

  it "should successfully return the show command with as_command_args" do
    @options[:as_command_args] = true
    @outputs.should_receive(:print).with('-a key1=value1 ')
    @outputs.should_receive(:print).with('-a key2=value2 ')
    @outputs.should_receive(:puts).with('')
    @outputs.show
  end

end
