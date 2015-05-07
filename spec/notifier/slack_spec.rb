require 'spec_helper'

describe SimpleDeploy::Notifier::Slack do
  include_context 'stubbed config'
  include_context 'double stubbed logger'

  before do
    @notifier = double('slack notifier')
    ::Slack::Notifier.stub(:new => @notifier)
    @config_mock.stub(:notifications => { 'slack' => { 'webhook_url' => 'url' } })
    @slack = SimpleDeploy::Notifier::Slack.new
  end

  it 'should send a message to slack' do
    @notifier.should_receive(:ping).with('message')
    @slack.send('message')
  end
end
