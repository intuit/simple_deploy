require 'spec_helper'

describe SimpleDeploy do

  before do
    @logger_stub = stub 'logger', :debug => true,
                                  :info  => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_stub
    @stack_mock = mock 'stack'
    SimpleDeploy.should_receive(:config).and_return(@config_mock)

    options = { :logger   => @logger_stub,
                :stack    => @stack_mock,
                :ssh_user => 'user',
                :name     => 'dastack' }
    @status = SimpleDeploy::Stack::Deployment::Status.new options
  end

  after do
    SimpleDeploy.release_config
  end

  describe "clear_for_deployment?" do
    it "should return true if clear for deployment" do
      @stack_mock.stub :attributes => { 'deployment_in_progress' => 'false' }
      @status.clear_for_deployment?.should be_true 
    end

    it "should return false if not clear for deployment" do
      @stack_mock.stub :attributes => { 'deployment_in_progress' => 'true' }
      @status.clear_for_deployment?.should be_false 
    end
  end

  describe "deployment_in_progress?" do
    it "should return false if no deployment in progress" do
      @stack_mock.stub :attributes => { 'deployment_in_progress' => 'false' }
      @status.deployment_in_progress?.should be_false
    end

    it "should return true if deployment in progress" do
      @stack_mock.stub :attributes => { 'deployment_in_progress' => 'true' }
      @status.deployment_in_progress?.should be_true
    end
  end

  describe "clear_deployment_lock" do
    it "should unset deploy in progress if force & deploy in progress" do
      @stack_mock.stub :attributes => { 'deployment_in_progress' => 'true' }
      @stack_mock.should_receive(:in_progress_update).
             with( { :attributes => [ { 'deployment_in_progress' => 'false' } ],
                     :caller => @status })
      @status.clear_deployment_lock(true)
    end
  end

  describe "set_deployment_in_prgoress" do
    it "set deployment as in progress" do
      Time.stub :now => 'thetime'
      @stack_mock.should_receive(:update).
             with( { :attributes => [ { "deployment_in_progress" => "true", "deployment_user" => "user", "deployment_datetime" => "thetime" } ] })
      @status.set_deployment_in_progress
    end
  end

  describe "unset_deployment_in_prgoress" do
    it "clears deployment in progress" do
      @stack_mock.should_receive(:in_progress_update).
             with( { :attributes => [ { 'deployment_in_progress' => 'false'} ],
                     :caller => @status })
      @status.unset_deployment_in_progress
    end
  end

end
