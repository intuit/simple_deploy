
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Protect do

  describe 'protect' do
    before do
      @config_mock  = mock 'config'
      @logger  = stub 'logger', 'info' => 'true'

      SimpleDeploy.should_receive(:create_config).and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
    end

    after do
      SimpleDeploy.release_config
    end

    it "should enable protection" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :protection  => 'on' }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'on' }
      stack.should_receive(:update).with(hash_including(:attributes => [{ 'protection' => 'on' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(stack)

      subject.protect
    end

    it "should enable protection for multiple stacks" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack1', 'my_stack2'],
                  :protection  => 'on' }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'on' }
      stack.should_receive(:update).twice.with(hash_including(:attributes => [{ 'protection' => 'on' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack1').
                          and_return(stack)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack2').
                          and_return(stack)

      subject.protect
    end

    it "should disable protection" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :protection  => 'off' }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'off' }
      stack.should_receive(:update).with(hash_including(:attributes => [{ 'protection' => 'off' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(stack)

      subject.protect
    end

    it "should disable protection for multiple stacks" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack1', 'my_stack2'],
                  :protection  => 'off' }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'off' }
      stack.should_receive(:update).twice.with(hash_including(:attributes => [{ 'protection' => 'off' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack1').
                          and_return(stack)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack2').
                          and_return(stack)

      subject.protect
    end
  end 
end
