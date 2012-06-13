require 'spec_helper'

describe Config do

  it "should create a new config object" do
    config = SimpleDeploy::Config.new
    config.class.should == SimpleDeploy::Config
  end

end

