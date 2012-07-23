require 'spec_helper'

describe SimpleDeploy do

  before do
    @config_mock = mock 'config mock'
    @logger_mock = mock 'logger mock'
    @config_mock.should_receive(:notifications).
                 and_return({ 'campfire' => 'settings' })
    @config_mock.should_receive(:logger).
                 and_return @logger_mock
    @notifier = SimpleDeploy::Notifier.new :stack_name  => 'stack_name',
                                           :environment => 'test',
                                           :config      => @config_mock

  end

  it "should include the github app & chef links if attributes present" do
    stack_mock = mock 'stack'
    campfire_mock = mock 'campfire mock'
    @config_mock.should_receive(:environment).and_return 'env_config'
    Stackster::Stack.should_receive(:new).
                     with(:environment => 'test',
                          :name        => 'stack_name',
                          :config      => 'env_config',
                          :logger      => @logger_mock).
                     and_return stack_mock
    stack_mock.should_receive(:attributes).
               and_return({ 'app_github_url'       => 'http://github.com/user/app',
                            'chef_repo_github_url' => 'http://github.com/user/chef_repo',
                            'app'                  => 'appsha',
                            'chef_repo'            => 'chefsha' })

    SimpleDeploy::Notifier::Campfire.should_receive(:new).
                                     and_return campfire_mock
    campfire_mock.should_receive(:send).
                  with "Deployment to stack_name complete. App: http://github.com/user/app/commits/appsha Chef: http://github.com/user/chef_repo/commits/chefsha"
    @notifier.send_deployment_complete_message
  end

  it "should send a message to each listed notification endpoint" do
    campfire_mock = mock 'campfire mock'
    SimpleDeploy::Notifier::Campfire.should_receive(:new).
                                     and_return campfire_mock
    campfire_mock.should_receive(:send).with 'heh you guys!'
    @notifier.send 'heh you guys!'
  end

end

