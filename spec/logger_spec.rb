require 'spec_helper'

describe SimpleDeploy do

  before do
    @logger_mock = mock 'logger'
  end

  context "with new logger" do
    before do
      @logger_mock.should_receive(:datetime_format=).with '%Y-%m-%dT%H:%M:%S%z'
      @logger_mock.should_receive(:formatter=)
      @logger_mock.should_receive(:level=).with 1
      Logger.should_receive(:new).with(STDOUT).and_return @logger_mock
    end

    it "should create a new logger object when one is not passed" do
      @logger = SimpleDeploy::SimpleDeployLogger.new
      @logger_mock.should_receive(:info).with 'a message'
      @logger.info 'a message'
    end

    it "accept puts with msg and pass it to debug" do
      @logger = SimpleDeploy::SimpleDeployLogger.new
      @logger_mock.should_receive(:debug).with 'a message'
      @logger.puts 'a message'
    end

    it "tty? return false" do
      @logger = SimpleDeploy::SimpleDeployLogger.new
      @logger.tty?.should be_false
    end
  end

  it "should create a new logger object from the hash passed as :logger" do
    Logger.should_receive(:new).exactly(0).times
    @logger = SimpleDeploy::SimpleDeployLogger.new :logger => @logger_mock
  end

end
