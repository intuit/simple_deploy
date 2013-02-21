require 'spec_helper'

describe SimpleDeploy::Template do
  before do
    @contents = {
                  "Parameters" => {
                    "Test1" => {
                      "Type"        => "String",
                      "Description" => "Test Param #1"
                    },
                    "Test2" => {
                      "Type"        => "String",
                      "Description" => "Test Param #2"
                    }
                  }
                }.to_json
    IO.should_receive(:read).with('/tmp/file').and_return @contents
    @template = SimpleDeploy::Template.new :file => '/tmp/file'
  end

  it "should return the parameters for a given template" do
    @template.parameters.should == ["Test1", "Test2"]
  end
end
