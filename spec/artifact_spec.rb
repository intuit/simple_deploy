require 'spec_helper'

describe SimpleDeploy do

  describe "an artifact" do

    context "when unencrypted" do
      before do
        @artifact = SimpleDeploy::Artifact.new :bucket_prefix => 'test_prefix',
                                               :domain        => 'us-west-1',
                                               :id            => 'abc123',
                                               :name          => 'myapp',
                                               :region        => 'us-west-1',
                                               :encrypted     => false
      end

      it "should return the endpoints for the artifact" do
        endpoints = { "s3"    => "s3://test_prefix-us-west-1/us-west-1/abc123.tar.gz", 
                      "http"  => "http://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz",
                      "https" => "https://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz" }
        @artifact.endpoints.should == endpoints
      end
    end

    context "when encrypted" do
      before do
        @artifact = SimpleDeploy::Artifact.new :bucket_prefix => 'test_prefix',
                                               :domain        => 'us-west-1',
                                               :id            => 'abc123',
                                               :name          => 'myapp',
                                               :region        => 'us-west-1',
                                               :encrypted     => true
      end

      it "should return the endpoints for the artifact" do
        endpoints = { "s3"    => "s3://test_prefix-us-west-1/us-west-1/abc123.tar.gz.gpg", 
                      "http"  => "http://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz.gpg",
                      "https" => "https://s3-us-west-1.amazonaws.com/test_prefix-us-west-1/us-west-1/abc123.tar.gz.gpg" }
        @artifact.endpoints.should == endpoints
      end
    end
  end
end
