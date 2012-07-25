require 'spec_helper'

describe SimpleDeploy do

  describe "an artifact" do

    before do
      @config_mock = mock 'config'
      @config_mock.should_receive(:artifact_domain).and_return('us-west-1')
      @artifact = SimpleDeploy::Artifact.new :bucket_prefix => 'test_prefix',
                                             :config        => @config_mock,
                                             :id            => 'abc123',
                                             :name          => 'myapp',
                                             :region        => 'us-west-1'
    end

    it "should return the endpoints for the artifact" do
      endpoints = { "s3"    => "s3://test_prefix-us-west-1/us-west-1/abc123.tar.gz", 
                    "http"  => "http://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz",
                    "https" => "https://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz" }
      @artifact.endpoints.should == endpoints
    end

  end
end
