require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy do

  it "should call the given sub command" do
    status_mock = mock 'status mock'
    ARGV.stub :shift => 'status'
    status_mock.should_receive(:show)
    SimpleDeploy::CLI::Status.should_receive(:new).and_return status_mock
    SimpleDeploy::CLI.start
  end

end

