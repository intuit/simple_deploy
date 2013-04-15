require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Create do
  include_context 'cli config'
  include_context 'double stubbed logger'
  include_context 'stubbed stack', :name        => 'mytest',
                                   :environment => 'test'

  before do
    @config_env            = mock 'environment config'
    @attribute_merger_mock = mock 'attribute merger'

    @options = { :attributes  => [ 'attr1=val1' ],
                 :input_stack => [ 'stack1' ],
                 :environment => 'test',
                 :name        => 'mytest',
                 :log_level   => 'info',
                 :template    => '/tmp/test.json' }
    Trollop.stub :options => @options

    SimpleDeploy.stub(:environments).and_return(@config_env)
    @config_env.should_receive(:keys).and_return(['test'])

    SimpleDeploy::Misc::AttributeMerger.stub :new => @attribute_merger_mock

    merge_options = { :attributes   => [ { "attr1" => "val1" } ], 
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
