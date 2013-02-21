require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Create do
  before do
    @config_object         = mock 'config'
    @config_env            = mock 'environment config'
    @stack_mock            = mock 'stack'
    @attribute_merger_mock = mock 'attribute merger'
    @logger                = stub 'logger', :info => true

    @options = { :attributes  => [ 'attr1=val1' ],
                 :input_stack => [ 'stack1' ],
                 :environment => 'test',
                 :name        => 'mytest',
                 :log_level   => 'info',
                 :template    => '/tmp/test.json' }
    Trollop.stub :options => @options
    SimpleDeploy::Config.stub :new => @config_object
    SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                     with(:log_level => 'info').
                                     and_return @logger
    @config_object.stub :environments => { 'test' => 'config_data' }
    @config_object.should_receive(:environment).with('test').
                   and_return 'config_data'
    SimpleDeploy::Stack.should_receive(:new).
                        with(:environment => 'test',
                             :name        => 'mytest',
                             :config      => 'config_data',
                             :logger      => @logger).
                        and_return(@stack_mock)
    SimpleDeploy::Misc::AttributeMerger.stub :new => @attribute_merger_mock
    merge_options = { :attributes   => [ { "attr1" => "val1" } ], 
                      :config       => 'config_data', 
                      :logger       => @logger,
                      :environment  => 'test',
                      :template     => '/tmp/test.json',
                      :input_stacks => ["stack1"] }
    @attribute_merger_mock.should_receive(:merge).with(merge_options).
                           and_return({ "attr1" => "val1",
                                        "attr2" => "val2" })
    @create = SimpleDeploy::CLI::Create.new
  end

  it "should create a stack with provided and merged attributes" do
    @stack_mock.should_receive(:create).
                with({ :attributes => { "attr1" => "val1",
                                        "attr2" => "val2" },
                       :template   => '/tmp/test.json' })
    @create.create
  end
end
