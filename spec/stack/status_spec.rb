require 'spec_helper'

describe SimpleDeploy::Status do

  before do
    @config_mock = mock 'config mock'
    @logger_mock = mock 'logger mock'
    @stack_reader_mock = mock 'stack reader mock'
    SimpleDeploy::StackReader.should_receive(:new).
                              and_return @stack_reader_mock
    @config_mock.should_receive(:logger).and_return @logger_mock
    @status = SimpleDeploy::Status.new :name   => 'test-stack',
                                       :config => @config_mock
  end

  it "should return true if the stack is in complete state" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'UPDATE_COMPLETE'
    @status.complete?.should == true
  end

  it "should return false if the stack is not in complete state" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'UPDATE_IN_PROGRESS'
    @status.complete?.should == false
  end

  it "should return true if the stack is in a failed state" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'DELETE_FAILED'
    @status.failed?.should == true
  end

  it "should return false if the stack is not in a failed state" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'UPDATE_IN_PROGRESS'
    @status.failed?.should == false
  end

  it "should return true if the stack is in an in_progress state" do
    @stack_reader_mock.should_receive(:status).exactly(2).times.
                      and_return 'UPDATE_IN_PROGRESS'
    @status.in_progress?.should == true
  end

  it "should return false if the stack is not in an in_progress state" do
    @stack_reader_mock.should_receive(:status).exactly(2).times.
                      and_return 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS'
    @status.in_progress?.should == false
  end

  it "should return true if the stack is cleaning up" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS'
    @status.cleanup_in_progress?.should == true
  end

  it "should return false if the stack is not in a cleaning up state" do
    @stack_reader_mock.should_receive(:status).
                      and_return 'UPDATE_IN_PROGRESS'
    @status.cleanup_in_progress?.should == false
  end

  it "should return true if the stack is in a complete state" do
    @stack_reader_mock.should_receive(:status).exactly(2).times.
                       and_return 'UPDATE_COMPLETE'
    @status.stable?.should == true
  end

  it "should return true if the stack is in a failed state" do
    @stack_reader_mock.should_receive(:status).exactly(3).times.
                      and_return 'UPDATE_FAILED'
    @status.stable?.should == true
  end

  it "should return true if the stack is in an in progress state" do
    @stack_reader_mock.should_receive(:status).exactly(2).times.
                      and_return 'IN_PROGRESS'
    @status.stable?.should == false
  end

  it "should return false if the stack creation failed" do
    @stack_reader_mock.should_receive(:status).exactly(3).times.
                      and_return 'CREATE_FAILED'
    @status.stable?.should == false
  end

  it "should return true when the stack is in a stable state" do
    @stack_reader_mock.should_receive(:status).exactly(4).times.
                      and_return 'CREATE_COMPLETE'
    @status.wait_for_stable.should == true
  end

  it "should sleep 2 times and return false when the stack is in an unstable state" do
    Kernel.stub!(:sleep)
    Kernel.should_receive(:sleep).with(1)
    Kernel.should_receive(:sleep).with(4)

    @stack_reader_mock.should_receive(:status).exactly(11).times.
                       and_return 'CREATE_FAILED'
    @logger_mock.should_receive(:info).exactly(2).times
    @status.wait_for_stable(2).should == false
  end

end
