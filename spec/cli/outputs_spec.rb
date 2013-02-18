require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Outputs do

  describe 'show' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger'
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack   = stub :attributes => { 'foo' => 'bar', 'baz' => 'blah' }
      SimpleDeploy::Config.stub(:new).and_return(@config)
      @config.should_receive(:environment).with('my_env').and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
      SimpleDeploy::Stack.should_receive(:new).
                          with(:config      => @config,
                               :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)
    end
  end

  it "should successfully return the show command" do
      subject = SimpleDeploy::CLI::Outputs.new
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(@options)
      subject.should_receive(:puts).with('foo: bar')
      subject.should_receive(:puts).with('baz: blah')
      subject.show
  end

  it "should return outputs as command line arguments" do
    outputs = SimpleDeploy::CLI::Outputs.new
    @data = [ { 'OutputKey' => 'key1', 'OutputValue' => 'value1' }, 
              { 'OutputKey' => 'key2', 'OutputValue' => 'value2' } ]

    outputs.should_receive(:print).with('-a key1=value1 ')
    outputs.should_receive(:print).with('-a key2=value2 ')
    outputs.should_receive(:puts).with('')
    outputs.command_args_output(@data)
  end

  it "should return the outputs in default format" do
    outputs = SimpleDeploy::CLI::Outputs.new
    @data = [ { 'OutputKey' => 'key1', 'OutputValue' => 'value1' }, 
              { 'OutputKey' => 'key2', 'OutputValue' => 'value2' } ]
    outputs.should_receive(:puts).with('key1: value1')
    outputs.should_receive(:puts).with('key2: value2')
    outputs.default_output(@data)
  end

end
