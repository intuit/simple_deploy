
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Update do
  describe 'update' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger', 'info' => 'true'
      @stack   = stub :attributes => {}

      SimpleDeploy::Config.stub(:new).and_return(@config)
      @config.should_receive(:environment).with('my_env').and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
    end

    it "should pass force true" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :attributes  => ['chef_repo_bucket_prefix=intu-lc'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:config      => @config,
                               :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => true))

      subject.update
    end

    it "should pass force false" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => false,
                  :attributes  => ['chef_repo_bucket_prefix=intu-lc'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:config      => @config,
                               :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => false))

      subject.update
    end
  end
end
