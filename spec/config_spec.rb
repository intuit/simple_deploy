require 'spec_helper'

describe SimpleDeploy do

  describe "after creating a configuration" do
    before do
      @config_data = { 'artifacts' => { 
                         'test_repo' => {
                           'bucket_prefix' => 'test_prefix',
                           'domain' => 'test_domain'
                          },
                         'test_repo2' => { },
                        },
                        'environments' => {
                          'test_env' => { 
                            'secret_key' => 'secret',
                            'access_key' => 'access',
                            'region'     => 'us-west-1'
                          }
                        },
                        'notifications' => {
                          'campfire' => {
                            'token' => 'my_token' 
                          }
                        }
                      }

      File.should_receive(:open).with("#{ENV['HOME']}/.simple_deploy.yml").
                                 and_return(@config_data.to_yaml)
      @config = SimpleDeploy::Config.new
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

    it "should return the domain (the folder in the s3 bucket) for an artifact" do
      @config.artifact_domain('test_repo').should == 'test_domain'
    end

    it "should return the name of an artifact for those without a set domain" do
      @config.artifact_domain('test_repo2').should == 'test_repo2'
    end

    it "should return the bucket prefix for the artifact" do
      @config.artifact_bucket_prefix('test_repo').should == 'test_prefix'
    end

    it "should return the environment requested" do
      @config.environment('test_env').should == ({ 'secret_key' => 'secret', 'access_key' => 'access', 'region' => 'us-west-1' })
    end

    it "should return the notifications available" do
      @config.notifications.should == ( { 'campfire' => { 'token' => 'my_token' } } )
    end

    it "should return the region for the environment" do
      @config.region('test_env').should == 'us-west-1'
    end

    it "should return the deploy script" do
      @config.deploy_script.should == '/opt/intu/admin/bin/configure.sh'
    end

  end

end
