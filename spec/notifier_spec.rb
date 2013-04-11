require 'spec_helper'

describe SimpleDeploy::Notifier do
  include_context 'stubbed config'

  describe "with valid settings" do
    before do
      @logger_mock = mock 'logger mock'
                   
      @config_mock.should_receive(:notifications).
                   exactly(1).times.
                   and_return({ 'campfire' => 'settings' })
      @notifier = SimpleDeploy::Notifier.new :stack_name  => 'stack_name',
                                             :environment => 'test',
                                             :logger      => @logger_mock
    end

    after do
      SimpleDeploy.release_config
    end

    it "should support a basic start message" do
      campfire_mock = mock 'campfire mock'

      @config_mock.should_receive(:region).and_return('us-west-1')

      SimpleDeploy::Notifier::Campfire.should_receive(:new).and_return campfire_mock
      campfire_mock.should_receive(:send).with "Deployment to stack_name in us-west-1 started."
      
      @notifier.send_deployment_start_message
    end

    it "should include the github app & chef links in the completed message" do
      stack_mock = mock 'stack'
      campfire_mock = mock 'campfire mock'
      environment_mock = mock 'environment mock'
      @config_mock.should_receive(:region).and_return('us-west-1')
      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'test',
                               :name        => 'stack_name',
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
                    with "Deployment to stack_name in us-west-1 complete. App: http://github.com/user/app/commit/appsha Chef: http://github.com/user/chef_repo/commit/chefsha"
      @notifier.send_deployment_complete_message
    end

    it "should send a message to each listed notification endpoint" do
      campfire_mock = mock 'campfire mock'
      SimpleDeploy::Notifier::Campfire.should_receive(:new).
                                       with(:environment => 'test',
                                            :stack_name  => 'stack_name',
                                            :logger      => @logger_mock).
                                       and_return campfire_mock
      campfire_mock.should_receive(:send).with 'heh you guys!'
      @notifier.send 'heh you guys!'
    end

  end

  it "should not blow up if the notification section is missing" do
    @logger_mock = mock 'logger mock'
                 
    @config_mock.should_receive(:notifications).
                 and_return nil
    @notifier = SimpleDeploy::Notifier.new :stack_name  => 'stack_name',
                                           :environment => 'test',
                                           :logger      => @logger_mock
    @notifier.send 'heh you guys!'
  end

end

