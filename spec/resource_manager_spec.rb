require 'spec_helper'

describe SimpleDeploy::ResourceManager do
  let(:config_data) do
    { 'environments' => {
        'test_env' => {
          'secret_key' => 'secret',
          'access_key' => 'access',
          'region'     => 'us-west-1'
      } },
      'notifications' => {
        'campfire' => {
          'token' => 'my_token'
      } } }
  end

  before do
    @manager = SimpleDeploy::ResourceManager.instance
  end

  describe "config" do
    it "should set environment via a setter" do
      @manager.environment = 'test_env'
      @manager.release_config
      config = @manager.config nil, :config => config_data

      config.environment.should == config_data['environments']['test_env']
      config.notifications.should == config_data['notifications']
    end

    it "should set environment through the config call" do
      @manager.environment = nil
      @manager.release_config
      config = @manager.config 'test_env', :config => config_data

      config.environment.should == config_data['environments']['test_env']
      config.notifications.should == config_data['notifications']
    end

    it "should throw IllegalStateException if environment is not set" do
      @manager.environment = nil
      @manager.release_config

      expect {
        config = @manager.config nil, :config => config_data
      }.to raise_error(SimpleDeploy::Exceptions::IllegalStateException)
    end
  end

  describe "environments" do
    it "should return the raw data for all environments" do
      environments = @manager.environments :config => config_data
      environments['test_env'].should == config_data['environments']['test_env']
    end
  end

  describe "valid_config?" do
    it "should return true for a valid config" do
      @manager.environment = nil
      @manager.release_config
      config = @manager.config 'test_env', :config => config_data

      @manager.valid_config?.should be_true
    end

    it "should return false for an invalid config" do
      @manager.release_config
      @manager.valid_config?.should_not be_true
    end
  end
end
