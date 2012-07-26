describe SimpleDeploy do
  before do
    @config_mock = mock 'config mock'
    @logger_mock = mock 'logger mock'
    @config_mock.should_receive(:region).with('preprod').
                 and_return 'us-west-1'
    @config_mock.should_receive(:logger).and_return @logger_mock

    options = { :config      => @config_mock,
                :environment => 'preprod' }
    @formater = SimpleDeploy::StackAttributeFormater.new options
  end

  it "should return updated attributes including cloud formation url" do
    artifact_mock = mock 'artifact'
    SimpleDeploy::Artifact.should_receive(:new).exactly(2).times.
                           with(:name => 'chef_repo',
                                :id   => 'test123',
                                :region => 'us-west-1',
                                :config => @config_mock,
                                :bucket_prefix => 'test-prefix').
                           and_return artifact_mock
    @config_mock.should_receive(:artifact_bucket_prefix).with('chef_repo').
                 exactly(2).times.
                 and_return('test-prefix')
    @config_mock.should_receive(:artifact_cloud_formation_url).with('chef_repo').
                 exactly(2).times.
                 and_return('CookBooksURL')
    @config_mock.should_receive(:artifacts).exactly(3).times.
                 and_return ['chef_repo', 'cookbooks', 'app']
    @logger_mock.should_receive(:info)
    artifact_mock.should_receive(:endpoints).exactly(2).times.
                                             and_return 's3' => 's3_url'
    @formater.updated_attributes([ { 'chef_repo' => 'test123' } ]).
              should == [ { "chef_repo" => "test123" }, 
                          { "CookBooksURL" =>"s3_url" } ]
  end
end
