require 'spec_helper'

describe SimpleDeploy::CLI::Attributes do

  describe 'show' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger'
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack   = stub :attributes => { 'foo' => 'bar', 'baz' => 'blah' }

      Trollop.stub(:options).and_return(@options)
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

    context 'by default' do
      it 'should validate the options and output the default' do
        SimpleDeploy::CLI::Shared.should_receive(:valid_options?).
                                  with(:provided => @options,
                                       :required => [:environment, :name])
        subject.should_receive(:puts).with("foo=bar")
        subject.should_receive(:puts).with("baz=blah")
        subject.show
      end
    end

  end

end
