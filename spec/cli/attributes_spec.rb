require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Attributes do

  describe 'show' do
    before do
      @config  = mock 'config'
      @logger  = stub 'logger'
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack   = stub :attributes => { 'foo' => 'bar', 'baz' => 'blah' }

      @resource_manager = SimpleDeploy::ResourceManager.instance
      @resource_manager.should_receive(:config).and_return(@config)
      SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                       with(:log_level => 'debug').
                                       and_return(@logger)
      SimpleDeploy::Stack.should_receive(:new).
                          with( :environment => 'my_env',
                               :logger      => @logger,
                               :name        => 'my_stack').
                          and_return(@stack)
    end

    after do
      @resource_manager.release_config
    end

    it 'should output the attributes' do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(@options)
      subject.should_receive(:puts).with('foo: bar')
      subject.should_receive(:puts).with('baz: blah')
      subject.show
    end

    context 'with --as-command-args' do
      before do
        @options[:as_command_args] = true
        Trollop.stub(:options).and_return(@options)
        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :name])
      end

      it 'should output the attributes as command arguments' do
        subject.should_receive(:puts).with("-a baz=blah -a foo=bar")
        subject.show
      end
    end

  end

end
