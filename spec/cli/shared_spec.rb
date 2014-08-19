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
    describe 'when providing both environment and read_from_env' do
      before { @provided = { environment: 'env', read_from_env: true } }

      it 'exits' do
        lambda {
          @object.valid_options? provided: @provided,
                                 required: [:environment, :read_from_env]
        }.should raise_error SystemExit
      end
    end

    describe 'when either environment or read from env is required' do
      before { @required = [:environment, :read_from_env] }

      describe 'and neither is provided' do
        it 'exits' do
          lambda {
            @object.valid_options? provided: {}, required: @required
          }.should raise_error SystemExit
        end
      end

      describe 'and environment is provided' do
        describe 'and the environment exists' do

          it 'does not exit' do
            config_stub = stub 'config stub',
                               environments: { 'prod' => 'data' },
                               keys: ['prod']

            provided = { :environment => 'prod', :test1 => 'value1' }
            required = [:environment, :read_from_env, :test1]

            SimpleDeploy.stub(:environments).and_return(config_stub)

            @object.valid_options? :provided => provided,
                                   :required => required,
                                   :logger   => @logger_stub
          end
        end

        describe 'and the environment does not exist' do

          it "exits" do
            config_stub = stub 'config stub',
                          environments: { 'preprod' => 'data' },
                          keys: ['preprod']

            provided = { :environment => 'prod' }
            required = [:environment, :read_from_env]

            SimpleDeploy.stub(:environments).and_return(config_stub)

            lambda {
              @object.valid_options? provided: provided,
                                     required: required
            }.should raise_error SystemExit
          end
        end
      end

      describe 'and read from env is provided' do
        describe 'and the env vars are set' do
          before do
            ENV['AWS_ACCESS_KEY_ID']     = 'access'
            ENV['AWS_SECRET_ACCESS_KEY'] = 'secret'
            ENV['AWS_REGION']            = 'us-west-1'
          end

          after do
            ENV['AWS_ACCESS_KEY_ID']     = nil
            ENV['AWS_SECRET_ACCESS_KEY'] = nil
            ENV['AWS_REGION']            = nil
          end

          it 'does not exit' do
            provided = { read_from_env: true, test1: 'value1' }
            required = [:environment, :read_from_env, :test1]

            @object.valid_options? :provided => provided,
                                   :required => required,
                                   :logger   => @logger_stub
          end

        end

        describe 'and the env vars are not set' do

          it 'exits' do
            provided = { read_from_env: true }
            required = [:environment, :read_from_env]

            # SimpleDeploy.stub(:environments).and_return(config_stub)

            lambda {
              @object.valid_options? provided: provided, required: required
            }.should raise_error SystemExit
          end

        end

      end

    end

    it "should exit if provided options passed do not include all required" do
      provided = { :test1 => 'test1', :test2 => 'test2' }
      required = [:test1, :test2, :test3]

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
