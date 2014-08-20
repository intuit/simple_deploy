require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Attributes do
  include_context 'cli config'
  include_context 'double stubbed logger'
  include_context 'double stubbed stack', :name        => 'my_stack',
                                          :environment => 'my_env'

  describe 'with --read-from-env' do
    before do
      @options = { :environment   => nil,
                   :log_level     => 'debug',
                   :name          => 'my_stack',
                   :read_from_env => true }
      @stack_stub.stub(:attributes).and_return({ 'foo' => 'bar', 'baz' => 'blah' })
    end

    it 'should output the attributes' do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name, :read_from_env])
      Trollop.stub(:options).and_return(@options)
      subject.should_receive(:puts).with('foo: bar')
      subject.should_receive(:puts).with('baz: blah')
      subject.show
    end
  end

  describe 'show' do
    before do
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack_stub.stub(:attributes).and_return({ 'foo' => 'bar', 'baz' => 'blah' })
    end

    it 'should output the attributes' do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name, :read_from_env])
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
                     :required => [:environment, :name, :read_from_env])
      end

      it 'should output the attributes as command arguments' do
        subject.should_receive(:puts).with("-a baz=blah -a foo=bar")
        subject.show
      end
    end

  end

end
