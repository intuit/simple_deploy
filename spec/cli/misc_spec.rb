require 'spec_helper'

describe SimpleDeploy::CLI::Misc::AttributeMerger do
  it "should return the consolidated list of attributes" do
    config_mock = mock 'config'
    mapper_mock = mock 'mapper'
    logger_stub = stub 'logger', :info => true
    stacks = ['stack1', 'stack2']

    options = { :config      => config_mock,
                :environment => 'default',
                :logger      => logger_stub,
                :attributes  => [ { 'attrib1' => 'val1' } ],
                :stacks      => stacks,
                :template    => '/tmp/file.json' }

    SimpleDeploy::StackOutputMapper.should_receive(:new).
                                    with(:environment => options[:environment],
                                         :config      => options[:config],
                                         :logger      => options[:logger]).
                                    and_return mapper_mock

    mapper_mock.should_receive(:map_outputs_from_stacks).
                with(:stacks => options[:stacks],
                     :template => options[:template]).
                and_return [ { 'attrib2' => 'val2' } ]

    merger = SimpleDeploy::CLI::Misc::AttributeMerger.new
    merger.merge(options).should == [ { 'attrib1' => 'val1' },
                                      { 'attrib2' => 'val2' } ]
  end
end
