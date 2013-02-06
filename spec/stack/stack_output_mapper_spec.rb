require 'spec_helper'

describe SimpleDeploy::StackOutputMapper do
  before do
    @config_mock = mock 'config'
    @logger_stub = stub 'logger'

    stack1_outputs = [ { 'OutputKey' => 'Test1', 'OutputValue' => 'val1' },
                       { 'OutputKey' => 'Nother', 'OutputValue' => 'another' } ]
    stack2_outputs = [ { 'OutputKey' => 'Test2', 'OutputValue' => 'val2' },
                       { 'OutputKey' => 'NotMe', 'OutputValue' => 'another' } ]
    stack3_outputs = [ { 'OutputKey' => 'Test1', 'OutputValue' => 'valA' } ]
    @stack1_stub = stub 'stack1', :outputs => stack1_outputs
    @stack2_stub = stub 'stack2', :outputs => stack2_outputs
    @stack3_stub = stub 'stack2', :outputs => stack3_outputs

    @template_stub = stub 'template', :parameters => ["Test1", "Test2"]

    @mapper = SimpleDeploy::StackOutputMapper.new :config      => @config_mock,
                                                  :environment => 'default',
                                                  :logger      => @logger_stub
  end

  it "should return the outputs which match parameters" do
    SimpleDeploy::Stack.should_receive(:new).
                        with(:environment => 'default',
                             :config      => @config_mock,
                             :logger      => @logger_stub,
                             :name        => 'stack1').
                        and_return @stack1_stub
    SimpleDeploy::Template.should_receive(:new).
                           with(:file => '/tmp/file.json').
                           and_return @template_stub
    @mapper.map_outputs_from_stacks(:stacks   => ['stack1'],
                                    :template => '/tmp/file.json').
            should == [{ 'Test1' => 'val1' }]
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
    SimpleDeploy::Template.should_receive(:new).
                           with(:file => '/tmp/file.json').
                           and_return @template_stub
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
    SimpleDeploy::Template.should_receive(:new).
                           with(:file => '/tmp/file.json').
                           and_return @template_stub
    @mapper.map_outputs_from_stacks(:stacks   => ['stack1', 'stack3'],
                                    :template => '/tmp/file.json').
            should == [{ 'Test1' => 'val1,valA' }]
  end 

  it "should return an empty hash if no stacks are specified" do
    @mapper.map_outputs_from_stacks(:stacks   => [],
                                    :template => '/tmp/file.json').
            should == []
  end

end
