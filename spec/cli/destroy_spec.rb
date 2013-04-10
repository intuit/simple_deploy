
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Destroy do

  describe 'destroy' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger', 'info' => 'true'
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack   = stub :attributes => {}

      SimpleDeploy.should_receive(:create_config).and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
    end

    after do
      SimpleDeploy.release_config
    end

    it "should exit with 0" do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(@options)

      @stack.should_receive(:destroy).and_return(true)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)

      begin
        subject.destroy
      rescue SystemExit => e
        e.status.should == 0
      end
    end

    it "should exit with 1" do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(@options)

      @stack.should_receive(:destroy).and_return(false)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)

      begin
        subject.destroy
      rescue SystemExit => e
        e.status.should == 1
      end
    end
  end 
end
