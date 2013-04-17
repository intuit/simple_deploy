require 'spec_helper'

describe SimpleDeploy::Stack::Execute do
  include_context 'stubbed config'
  include_context 'double stubbed stack', :name        => 'my_stack',
                                          :environment => 'my_env'

  before do
    @ssh_mock = mock 'ssh'
    options = { :instances   => @instances,
                :environment => @environment,
                :ssh_user    => @ssh_user,
                :ssh_key     => @ssh_key,
                :stack       => @stack_stub,
                :name        => @name }


    SimpleDeploy::Stack::SSH.should_receive(:new).
                             with(options).
                             and_return @ssh_mock
    @execute = SimpleDeploy::Stack::Execute.new options
  end

  it "should call execute with the given options" do
    options = { :sudo => true, :command => 'uname' }
    @ssh_mock.should_receive(:execute).
              with(options).
              and_return true
    @execute.execute(options).should be_true
  end
end
