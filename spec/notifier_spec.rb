require 'spec_helper'

describe SimpleDeploy do

  before do
    @config_mock = mock 'config mock'
    @config_mock.should_receive(:notifications).
                 and_return({ 'campfire' => 'settings' })
    @notifier = SimpleDeploy::Notifier.new :stack_name  => 'stack_name',
                                           :environment => 'test',
                                           :config      => @config_mock

  end

  it "should send a message to each listed notification endpoint" do
    campfire_mock = mock 'campfire mock'
    SimpleDeploy::Notifier::Campfire.should_receive(:new).
                                     and_return campfire_mock
    campfire_mock.should_receive(:send).with :message => 'heh you guys!'
    @notifier.send 'heh you guys!'
  end

end

