
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Protect do
  include_context 'cli config'
  include_context 'double stubbed logger'

  describe 'protect' do
    before do
      @options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack1'],
                  :protection  => 'on' }
    end

    context "single stack" do
      include_context 'received stack array', 'my_stack', 'my_env', 1
      
      it "should enable protection" do
        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :name])
        Trollop.stub(:options).and_return(@options)

        @stack_mock1.stub(:attributes).and_return('protection' => 'on')
        @stack_mock1.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'on' }]))

        subject.protect
      end

      it "should disable protection" do
        @options[:protection]= 'off'

        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :name])
        Trollop.stub(:options).and_return(@options)

        @stack_mock1.stub(:attributes).and_return('protection' => 'off')
        @stack_mock1.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'off' }]))

        subject.protect
      end
    end

    context "multiple stacks" do
      include_context 'received stack array', 'my_stack', 'my_env', 2

      it "should enable protection" do
        @options[:name] = ['my_stack1', 'my_stack2']

        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :name])
        Trollop.stub(:options).and_return(@options)

        @stack_mock1.stub(:attributes).and_return('protection' => 'on')
        @stack_mock1.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'on' }]))
        @stack_mock2.stub(:attributes).and_return('protection' => 'on')
        @stack_mock2.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'on' }]))

        subject.protect
      end

      it "should disable protection" do
        @options[:name] = ['my_stack1', 'my_stack2']
        @options[:protection]= 'off'

        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :name])
        Trollop.stub(:options).and_return(@options)

        @stack_mock1.stub(:attributes).and_return('protection' => 'off')
        @stack_mock1.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'off' }]))
        @stack_mock2.stub(:attributes).and_return('protection' => 'off')
        @stack_mock2.should_receive(:update).with(
          hash_including(:attributes => [{ 'protection' => 'off' }]))

        subject.protect
      end
    end

  end 
end
