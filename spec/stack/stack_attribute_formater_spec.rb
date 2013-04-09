require 'spec_helper'

describe SimpleDeploy do
  before do
    @logger_mock = mock 'logger mock', :info => 'true'
    @config_mock = mock 'config mock', :logger => @logger_mock, :region => 'us-west-1'
    @config_mock.stub(:artifact_cloud_formation_url).and_return('ChefRepoURL')
    @config_mock.stub(:artifacts).and_return(['chef_repo', 'cookbooks', 'app'])

    @resource_manager = SimpleDeploy::ResourceManager.instance
    @resource_manager.should_receive(:config).and_return(@config_mock)
  end

  after do
    @resource_manager.release_config
  end

  context "when chef_repo unencrypted" do
    before do
      options = { :logger      => @logger_mock,
                  :environment => 'preprod',
                  :main_attributes => {
                    'chef_repo_bucket_prefix' => 'test-prefix',
                    'chef_repo_domain'        => 'test-domain' }
                }
      @formater = SimpleDeploy::StackAttributeFormater.new options
    end

    it 'should return updated attributes including the un encrypted cloud formation url' do
      updates = @formater.updated_attributes([ { 'chef_repo' => 'test123' } ])
      updates.should == [{ 'chef_repo' => 'test123' }, 
                         { 'ChefRepoURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }]
    end
  end

  context "when main_attributes set chef_repo encrypted" do
    before do
      options = { :logger      => @logger_mock,
                  :environment => 'preprod',
                  :main_attributes => {
                    'chef_repo_bucket_prefix' => 'test-prefix',
                    'chef_repo_encrypted'     => 'true',
                    'chef_repo_domain'        => 'test-domain' }
                }
      @formater = SimpleDeploy::StackAttributeFormater.new options
    end

    it 'should return updated attributes including the encrypted cloud formation url ' do
      updates = @formater.updated_attributes([ { 'chef_repo' => 'test123' } ])
      updates.should == [{ 'chef_repo' => 'test123' }, 
                         { 'ChefRepoURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz.gpg' }]
    end
  end

  context "when provided attributes set chef_repo encrypted" do
    before do
      options = { :logger      => @logger_mock,
                  :environment => 'preprod',
                  :main_attributes => {
                    'chef_repo_bucket_prefix' => 'test-prefix',
                    'chef_repo_domain'        => 'test-domain' }
                }
      @formater = SimpleDeploy::StackAttributeFormater.new options
    end

    it 'should return updated attributes including the encrypted cloud formation url ' do
      updates = @formater.updated_attributes([ { 'chef_repo' => 'test123' }, 
                                               { 'chef_repo_encrypted' => 'true' } ])
      updates.should == [{ 'chef_repo' => 'test123' },
                         { 'chef_repo_encrypted' => 'true' },
                         { 'ChefRepoURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz.gpg' }]
    end
  end
end
