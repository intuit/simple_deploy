require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Attributes do
  include_context 'cli config'
  include_context 'double stubbed logger'

  describe 'show' do
    before do
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack   = stub :attributes => { 'foo' => 'bar', 'baz' => 'blah' }

      SimpleDeploy::Stack.should_receive(:new).
                          with( :environment => 'my_env',
                                :name        => 'my_stack').
                          and_return(@stack)
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
