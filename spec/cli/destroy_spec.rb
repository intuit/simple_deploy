
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Destroy do
  include_context 'cli config'
  include_context 'double stubbed logger'
  include_context 'stubbed stack', :name        => 'my_stack',
                                   :environment => 'my_env'

  describe 'destroy' do
    before do
      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => 'my_stack' }
      @stack_mock.stub(:attributes).and_return({})
    end

    it "should exit with 0" do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])
      Trollop.stub(:options).and_return(@options)

      @stack_mock.should_receive(:destroy).and_return(true)

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

      @stack_mock.should_receive(:destroy).and_return(false)

      begin
        subject.destroy
      rescue SystemExit => e
        e.status.should == 1
      end
    end
  end 
end
