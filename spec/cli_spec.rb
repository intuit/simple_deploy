require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy do

  it "should call the given sub command" do
    status_mock = mock 'status mock'
    ARGV.stub :shift => 'status'
    status_mock.should_receive(:show)
    SimpleDeploy::CLI::Status.stub :new => status_mock
    SimpleDeploy::CLI.start
  end

  describe 'environments' do
    let(:env) { mock('env').tap { |m| m.should_receive(:environments) } }

    before do
      ARGV.stub :shift => 'environments'
      SimpleDeploy::CLI::Environments.stub :new => env
    end

    it 'calls the correct command' do
      SimpleDeploy::CLI.start
    end

    context 'envs' do
      before { ARGV.stub :shift => 'envs'}

      it 'calls the correct command' do
        SimpleDeploy::CLI.start
      end
    end

  end

end

