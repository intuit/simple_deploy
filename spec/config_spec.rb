require 'spec_helper'

describe SimpleDeploy::Configuration do
  let(:config_data) do
    { 'environments' => {
        'test_env' => {
          'access_key'     => 'access',
          'secret_key'     => 'secret',
          'security_token' => 'token',
          'region'         => 'us-west-1'
      } },
      'notifications' => {
        'campfire' => {
          'token' => 'my_token'
      } } }
  end

  describe 'creating a configuration' do
    before do
      @the_module = SimpleDeploy::Configuration
    end

    it 'should accept config data as an argument' do
      YAML.should_not_receive(:load)

      @config = @the_module.configure 'test_env', :config => config_data
      @config.environment.should == config_data['environments']['test_env']
      @config.notifications.should == config_data['notifications']
    end

    it 'should load the config from ~/.simple_deploy.yml by default' do
      File.should_receive(:open).with("#{ENV['HOME']}/.simple_deploy.yml").
                                 and_return(config_data.to_yaml)

      @config = @the_module.configure 'test_env'
      @config.environment.should == config_data['environments']['test_env']
      @config.notifications.should == config_data['notifications']
    end

    it 'should load the config from SIMPLE_DEPLOY_CONFIG_FILE if supplied' do
      File.should_receive(:open).with("/my/config/file").
                                 and_return(config_data.to_yaml)
      env_mock = mock 'env'
      @the_module.stub(:env).and_return(env_mock)
      env_mock.should_receive(:load).
               with('SIMPLE_DEPLOY_CONFIG_FILE').
               and_return "/my/config/file"
      @config = @the_module.configure 'test_env'
      @config.environment.should == config_data['environments']['test_env']
      @config.notifications.should == config_data['notifications']
    end

    describe 'when the environment is :read_from_env' do
      before do
        ENV['AWS_ACCESS_KEY_ID']     = 'env_access'
        ENV['AWS_REGION']            = 'env_region'
        ENV['AWS_SECRET_ACCESS_KEY'] = 'env_secret'
        ENV['AWS_SECURITY_TOKEN']    = 'env_token'

        @data = {
          'access_key'     => 'env_access',
          'region'         => 'env_region',
          'secret_key'     => 'env_secret',
          'security_token' => 'env_token'
        }
      end

      after do
        %w(ACCESS_KEY_ID REGION SECRET_ACCESS_KEY SECURITY_TOKEN).each do |i|
          ENV["AWS_#{i}"] = nil
        end
      end

      it 'loads the config from env vars' do
        @config = @the_module.configure :read_from_env
        @config.environment.should eq(@data)
        @config.notifications.should eq({})
      end
    end

  end

  describe "after creating a configuration" do
    before do
      @the_module = SimpleDeploy::Configuration
      @config = @the_module.configure 'test_env', :config => config_data
    end

    it "should return the default artifacts to deploy" do
      @config.artifacts.should == ['chef_repo', 'cookbooks', 'app']
    end

    it "should return the APP_URL for app" do
      @config.artifact_deploy_variable('app').should == 'APP_URL'
    end

    it "should return the Cloud Formation camel case variables" do
      @config.artifact_cloud_formation_url('app').should == 'AppArtifactURL'
    end

    it "should return the environment requested" do
      env_config = @config.environment
      env_config['access_key'].should == 'access'
      env_config['secret_key'].should == 'secret'
      env_config['security_token'].should == 'token'
      env_config['region'].should == 'us-west-1'
    end

    it "should return the notifications available" do
      @config.notifications.should == ( { 'campfire' => { 'token' => 'my_token' } } )
    end

    it "should return the access_key for the environment" do
      @config.access_key.should == 'access'
    end

    it "should return the secret_key for the environment" do
      @config.secret_key.should == 'secret'
    end

    it "should return the security token for the environment" do
      @config.security_token.should == 'token'
    end

    it "should return the region for the environment" do
      @config.region.should == 'us-west-1'
    end

    it "should return the deploy script" do
      @config.deploy_script.should == '/opt/intu/admin/bin/configure.sh'
    end

  end

  describe 'showing raw configuration for all instances' do
    before do
      @the_module = SimpleDeploy::Configuration
    end

    it "should return a hash for every environment" do
      environments = @the_module.environments :config => config_data
      environments.keys.should == ['test_env']
    end
  end

  describe "gracefully handling yaml file errors" do
    before do
      FakeFS.activate!
      @config_file_path = "#{ENV['HOME']}/.simple_deploy.yml"
      FileUtils.mkdir_p File.dirname(@config_file_path)

      @the_module = SimpleDeploy::Configuration
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    it "should handle a missing file gracefully" do
      expect {
        config = @the_module.configure 'test_env'
      }.to raise_error(RuntimeError, "#{@config_file_path} not found")
    end

    it "should handle a corrupt file gracefully" do
      s = "---\nport: | 80"
      File.open(@config_file_path, 'w') do |out|
        out.write(s)
      end

      expect {
        config = @the_module.configure 'test_env'
      }.to raise_error(RuntimeError, "#{@config_file_path} is corrupt")
    end
  end
end
