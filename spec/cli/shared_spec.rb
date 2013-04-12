require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Shared do
  include_context 'double stubbed logger'

  before do
    @object = Object.new
    @object.extend SimpleDeploy::CLI::Shared
  end

  it "should parse the given attributes" do
    logger_stub = stub 'logger stub', :info => true
    attributes  = [ 'test1=value1', 'test2=value2==' ]

    @object.parse_attributes(:logger     => @logger_stub,
                             :attributes => attributes).
           should == [ { "test1" => "value1" }, 
                       { "test2" => "value2==" } ]
  end

  context "validating options " do
    it "should exit if provided options passed do not include all required" do
      provided = { :test1 => 'test1', :test2 => 'test2' }
      required = [:test1, :test2, :test3]

      lambda { 
        @object.valid_options? :provided => provided,
                               :required => required
             }.should raise_error SystemExit
    end

    it "should exit if environment does not exist" do
      config_stub = stub 'config stub', :environments => { 'preprod' => 'data' }

      provided = { :environment => 'prod' }
      required = [:environment]

      SimpleDeploy.stub(:environments).and_return(config_stub)
      config_stub.should_receive(:keys).and_return(['preprod'])

      lambda { 
        @object.valid_options? :provided => provided,
                               :required => required
             }.should raise_error SystemExit
    end

    it "should not exit if all options passed and environment exists" do
      config_stub = stub 'config stub', :environments => { 'prod' => 'data' }

      provided = { :environment => 'prod', :test1 => 'value1' }
      required = [:environment, :test1]

      SimpleDeploy.stub(:environments).and_return(config_stub)
      config_stub.should_receive(:keys).and_return(['prod'])

      @object.valid_options? :provided => provided,
                             :required => required,
                             :logger   => @logger_stub
    end
  end

  it "should return the command name" do
    @object.command_name.should == 'object'
  end

  it "should rescue exceptions and exit 1" do
    lambda { @object.rescue_exceptions_and_exit do
               raise SimpleDeploy::Exceptions::Base
             end 
           }.should raise_error SystemExit
  end
end
