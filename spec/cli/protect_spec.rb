
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Protect do

  describe 'protect' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger', 'info' => 'true'

      SimpleDeploy::Config.stub(:new).and_return(@config)
      @config.should_receive(:environment).with('my_env').and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
    end

    it "should enable protection" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => 'my_stack',
                  :attributes  => ['protection=on'] }

      SimpleDeploy::CLI::Shared.should_receive(:valid_options?).
                                with(:provided => options,
                                     :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'on' }
      stack.should_receive(:update).with(hash_including(:attributes => [{ 'protection' => 'on' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:config      => @config,
                               :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(stack)

      subject.protect
    end

    it "should disable protection" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => 'my_stack',
                  :attributes  => ['protection=off'] }

      SimpleDeploy::CLI::Shared.should_receive(:valid_options?).
                                with(:provided => options,
                                     :required => [:environment, :name])
      Trollop.stub(:options).and_return(options)

      stack   = stub :attributes => { 'protection' => 'off' }
      stack.should_receive(:update).with(hash_including(:attributes => [{ 'protection' => 'off' }]))

      SimpleDeploy::Stack.should_receive(:new).
                          with(:config      => @config,
                               :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(stack)

      subject.protect
    end
  end 
end
