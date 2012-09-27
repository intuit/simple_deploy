require 'spec_helper'

describe SimpleDeploy do
  before do
    @logger_mock = mock 'logger mock', :info => 'true'
    @config_mock = mock 'config mock', :logger => @logger_mock, :region => 'us-west-1'
    @config_mock.stub(:artifact_cloud_formation_url).and_return('CookBooksURL')
    @config_mock.stub(:artifacts).and_return(['chef_repo', 'cookbooks', 'app'])

    options = { :config      => @config_mock,
                :environment => 'preprod',
                :main_attributes => {
                  'chef_repo_bucket_prefix' => 'test-prefix',
                  'chef_repo_domain' => 'test-domain' }
              }
    @formater = SimpleDeploy::StackAttributeFormater.new options
  end

  it 'should return updated attributes including the cloud formation url' do
    updates = @formater.updated_attributes([ { 'chef_repo' => 'test123' } ])
    updates.should == [{ 'chef_repo' => 'test123' }, { 'CookBooksURL' => 's3://test-prefix-us-west-1/test-domain/test123.tar.gz' }]
  end
end
