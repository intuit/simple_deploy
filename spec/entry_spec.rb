require 'spec_helper'

describe SimpleDeploy::Entry do
  let(:config_data) do
    { 'environments' => {
        'test_env' => {
          'secret_key' => 'the-key',
          'access_key' => 'access',
          'region'     => 'us-west-1'
      } } }
  end

  before do
    @logger_stub = stub 'logger stub', :info => 'true', :warn => 'true', :debug => 'true'
  end

  it "should create a new entry object" do
    @simple_db_mock = mock 'simple db'
    config = SimpleDeploy::Config.new(:config => config_data).environment('test_env')
    SimpleDeploy::AWS::SimpleDB.should_receive(:new).and_return @simple_db_mock
    @simple_db_mock.should_receive(:create_domain).
                    with("stacks").
                    and_return true
    entry = SimpleDeploy::Entry.new :config => config,
                                    :logger => @logger_stub,
                                    :name   => 'test-stack'
    entry.class.should == SimpleDeploy::Entry
  end
  
  it "should find the requested stack in simple db" do
    @simple_db_mock = mock 'simple db'
    config = SimpleDeploy::Config.new(:config => config_data).environment('test_env')
    SimpleDeploy::AWS::SimpleDB.should_receive(:new).and_return @simple_db_mock

    @simple_db_mock.should_receive(:create_domain).
                    with("stacks").
                    and_return true
    SimpleDeploy::Entry.find :name   => 'stack-to-find',
                             :logger => @logger_stub,
                             :config => config
  end

  context "with stack object" do
    before do
      @config = SimpleDeploy::Config.new(:config => config_data).environment('test_env')
      @simple_db_mock = mock 'simple db'
      SimpleDeploy::AWS::SimpleDB.should_receive(:new).and_return @simple_db_mock
      @simple_db_mock.should_receive(:create_domain).
                      with("stacks").
                      and_return true
      @entry = SimpleDeploy::Entry.new :config => @config,
                                       :logger => @logger_stub,
                                       :name   => 'test-stack'
    end

    it "should set the name to region-name for the stack" do
      @entry.name.should == 'test-stack-us-west-1'
    end

    it "should set the attributes in simple db including default attributes" do
      Timecop.travel Time.utc(2012, 10, 22, 13, 30)

      @simple_db_mock.should_receive(:select).
                      with("select * from stacks where itemName() = 'test-stack-us-west-1'").
                      and_return('test-stack-us-west-1' => { 'key1' => ['value1'] })
      @simple_db_mock.should_receive(:put_attributes).
                      with("stacks", 
                           "test-stack-us-west-1", 
                           { "key"       => "value",
                             "key1"      => "value1",
                             "Name"      => "test-stack-us-west-1",
                             "CreatedAt" => "2012-10-22 13:30:00 UTC" }, 
                           { :replace => ["key1", "key", "Name", "CreatedAt"] } )
      @entry.set_attributes(['key' => 'value'])
      
      @entry.save
    end

    it "should merge custom attributes" do
      @simple_db_mock.should_receive(:select).
                      with("select * from stacks where itemName() = 'test-stack-us-west-1'").
                      and_return('test-stack' => { 'key1' => ['value1'] })
      @entry.set_attributes(['key1' => 'value2'])

      @entry.attributes.should == {'key1' => 'value2' }
    end
  end

end
