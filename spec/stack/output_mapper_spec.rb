require 'spec_helper'

describe SimpleDeploy::Stack::OutputMapper do
  before do
    @config_mock = mock 'config'
    @logger_stub = stub 'logger', :debug => true, :info => true

    stack1_outputs = [ { 'OutputKey' => 'Test1', 'OutputValue' => 'val1' },
                       { 'OutputKey' => 'Nother', 'OutputValue' => 'another' } ]

    stack2_outputs = [ { 'OutputKey' => 'Test2', 'OutputValue' => 'val2' },
                       { 'OutputKey' => 'NotMe', 'OutputValue' => 'another' } ]

    stack3_outputs = [ { 'OutputKey' => 'Test1', 'OutputValue' => 'valA' } ]

    stack4_outputs = [ { 'OutputKey' => 'Test', 'OutputValue' => 'val' } ]

    @stack1_stub = stub 'stack1', :outputs => stack1_outputs, :wait_for_stable => true
    @stack2_stub = stub 'stack2', :outputs => stack2_outputs, :wait_for_stable => true
    @stack3_stub = stub 'stack3', :outputs => stack3_outputs, :wait_for_stable => true
    @stack4_stub = stub 'stack4', :outputs => stack4_outputs, :wait_for_stable => true

    @template_stub = stub 'template', :parameters => ["Test1", "Test2", "Tests"]

    @mapper = SimpleDeploy::Stack::OutputMapper.new :config      => @config_mock,
                                                    :environment => 'default',
                                                    :logger      => @logger_stub
  end

  context "when provided stacks" do
    before do
      SimpleDeploy::Template.should_receive(:new).
                             with(:file => '/tmp/file.json').
                             and_return @template_stub
    end

    it "should return the outputs which match parameters" do
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack1').
                          and_return @stack1_stub
      @mapper.should_receive(:sleep)
      @mapper.map_outputs_from_stacks(:stacks   => ['stack1'],
                                      :template => '/tmp/file.json').
              should == [{ 'Test1' => 'val1' }]
    end

    it "should return the outputs which match pluralized parameters" do
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack4').
                          and_return @stack4_stub
      @mapper.should_receive(:sleep)
      @mapper.map_outputs_from_stacks(:stacks   => ['stack4'],
                                      :template => '/tmp/file.json').
              should == [{ 'Tests' => 'val' }]
    end

    it "should return the outputs which match parameters from multiple stacks" do
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack1').
                          and_return @stack1_stub
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack2').
                          and_return @stack2_stub
      @mapper.should_receive(:sleep).exactly(3).times
      @mapper.map_outputs_from_stacks(:stacks   => ['stack1', 'stack2'],
                                      :template => '/tmp/file.json').
              should == [{ 'Test1' => 'val1' }, {'Test2' => 'val2' }]
    end

    it "should concatenate multiple outputs of same name into CSV" do
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack1').
                          and_return @stack1_stub
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'default',
                               :config      => @config_mock,
                               :logger      => @logger_stub,
                               :name        => 'stack3').
                          and_return @stack3_stub
      @mapper.should_receive(:sleep).exactly(3).times
      @mapper.map_outputs_from_stacks(:stacks   => ['stack1', 'stack3'],
                                      :template => '/tmp/file.json').
              should == [{ 'Test1' => 'val1,valA' }]
    end
  end

  it "should return an empty hash if no stacks are specified" do
    @mapper.map_outputs_from_stacks(:stacks   => [],
                                    :template => '/tmp/file.json').
            should == []
  end

end
