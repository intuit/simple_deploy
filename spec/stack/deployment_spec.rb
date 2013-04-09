require 'spec_helper'

describe SimpleDeploy do

  before do
    @attributes = { 'key'                     => 'val',
                    'chef_repo'               => 'chef_repo',
                    'chef_repo_bucket_prefix' => 'chef_repo_bp',
                    'chef_repo_domain'        => 'chef_repo_d',
                    'app'                     => 'app',
                    'app_bucket_prefix'       => 'app_bp',
                    'app_domain'              => 'app_d',
                    'cookbooks'               => 'cookbooks',
                    'cookbooks_bucket_prefix' => 'cookbooks_bp',
                    'cookbooks_domain'        => 'cookbooks_d' }
    @logger_stub = stub 'logger stub'
    @logger_stub.stub :debug => 'true', 
                      :info  => 'true',
                      :error => 'true'

    @config_mock = mock 'config mock'
    @config_mock.stub(:region) { 'test-us-west-1' }

    @stack_mock = mock 'stack mock'
    @stack_mock.stub(:attributes) { @attributes }

    @status_mock = mock 'status mock'

    @resource_manager = SimpleDeploy::ResourceManager.instance
    @resource_manager.should_receive(:config).and_return(@config_mock)

    options = { :logger      => @logger_stub,
                :instances   => ['1.2.3.4', '4.3.2.1'],
                :environment => 'test-us-west-1',
                :ssh_user    => 'user',
                :ssh_key     => 'key',
                :stack       => @stack_mock,
                :name        => 'stack-name' }
    @deployment = SimpleDeploy::Stack::Deployment.new options
    @deployment.stub(:sleep) { false }
  end

  after do
    @resource_manager.release_config
  end

  context "manage locks" do
    before do
      status_options = { :name        => 'stack-name',
                         :environment => 'test-us-west-1',
                         :ssh_user    => 'user',
                         :logger      => @logger_stub,
                         :stack       => @stack_mock }
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              with(status_options).
                                              and_return @status_mock
    end

    describe "clear_for_deployment?" do
      it "should test the clear_for_deployment method" do
        @status_mock.stub :clear_for_deployment? => true
        @deployment.clear_for_deployment?.should be_true
      end
    end

    describe "clear_deployment_lock" do
      it "should test the clear_deployment_lock" do
        @status_mock.should_receive(:clear_deployment_lock).
                     with(true).
                     and_return true
        @deployment.clear_deployment_lock(true).should be_true
      end
    end

  end

  describe "executing a deploy" do
    before do
      @config_mock.stub(:artifacts) { ['chef_repo', 'cookbooks', 'app'] }
      @config_mock.stub(:deploy_script) { '/tmp/script' }
      @stack_mock.stub(:instances) { [ { 'instancesSet' =>
                                     [ { 'privateIpAddress' => '10.1.2.3' } ] } ] }
 
      status_options = { :name        => 'stack-name',
                         :environment => 'test-us-west-1',
                         :ssh_user    => 'user',
                         :logger      => @logger_stub,
                         :stack       => @stack_mock }
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              with(status_options).
                                              and_return @status_mock
    end

    describe "when successful" do
        before do
          @execute_mock = mock "execute"
          execute_options = { :name        => 'stack-name',
                              :environment => 'test-us-west-1',
                              :instances   => ['1.2.3.4', '4.3.2.1'],
                              :ssh_user    => 'user',
                              :ssh_key     => 'key',
                              :logger      => @logger_stub,
                              :stack       => @stack_mock }
          SimpleDeploy::Stack::Execute.should_receive(:new).
                                       with(execute_options).
                                       and_return @execute_mock
          @config_mock.should_receive(:artifact_deploy_variable).
                       with("cookbooks").
                       and_return('CHEF_REPO_URL')
          @config_mock.should_receive(:artifact_deploy_variable).
                       with("app").
                       and_return('APP_URL')
          @config_mock.should_receive(:artifact_deploy_variable).
                       with("chef_repo").
                       and_return('CHEF_REPO_URL')
        end

      context "when app encrypted" do
        before do
          @attributes['app_encrypted'] = 'true'
          @execute_mock.should_receive(:execute).
                        with( {:sudo=>true, :command=>"env CHEF_REPO_URL=s3://cookbooks_bp-test-us-west-1/cookbooks_d/cookbooks.tar.gz APP_URL=s3://app_bp-test-us-west-1/app_d/app.tar.gz.gpg PRIMARY_HOST=10.1.2.3 /tmp/script"} )
        end

        it "should deploy if the stack is clear to deploy" do
          @status_mock.stub :clear_for_deployment? => true
          @status_mock.should_receive(:set_deployment_in_progress)
          @status_mock.should_receive(:unset_deployment_in_progress)
          @stack_mock.should_receive(:raw_instances).at_least(:once).and_return(
                      [{ 'instancesSet' => [ { 'privateIpAddress' => '10.1.2.3' } ] }])
          @deployment.execute(false).should be_true
        end

        it "should deploy if the stack is not clear to deploy but forced and clear in time" do
          @status_mock.stub :clear_for_deployment? => false,
                            :clear_deployment_lock => true,
                            :clear_for_deployment? => true
          @status_mock.should_receive(:set_deployment_in_progress)
          @status_mock.should_receive(:unset_deployment_in_progress)
          @stack_mock.should_receive(:raw_instances).at_least(:once).and_return(
                      [{ 'instancesSet' => [ { 'privateIpAddress' => '10.1.2.3' } ] }])
          @deployment.execute(true).should be_true
        end
      end

      context "when unencrypted" do
        before do
          @execute_mock.should_receive(:execute).
                        with( {:sudo=>true, :command=>"env CHEF_REPO_URL=s3://cookbooks_bp-test-us-west-1/cookbooks_d/cookbooks.tar.gz APP_URL=s3://app_bp-test-us-west-1/app_d/app.tar.gz PRIMARY_HOST=10.1.2.3 /tmp/script"} )
        end

        it "should deploy if the stack is clear to deploy" do
          @status_mock.stub :clear_for_deployment? => true
          @status_mock.should_receive(:set_deployment_in_progress)
          @status_mock.should_receive(:unset_deployment_in_progress)
          @stack_mock.should_receive(:raw_instances).at_least(:once).and_return(
                      [{ 'instancesSet' => [ { 'privateIpAddress' => '10.1.2.3' } ] }])
          @deployment.execute(false).should be_true
        end

        it "should deploy if the stack is not clear to deploy but forced and clear in time" do
          @status_mock.stub :clear_for_deployment? => false,
                            :clear_deployment_lock => true,
                            :clear_for_deployment? => true
          @status_mock.should_receive(:set_deployment_in_progress)
          @status_mock.should_receive(:unset_deployment_in_progress)
          @stack_mock.should_receive(:raw_instances).at_least(:once).and_return(
                      [{ 'instancesSet' => [ { 'privateIpAddress' => '10.1.2.3' } ] }])
          @deployment.execute(true).should be_true
        end
      end
    end

    describe "when unsuccessful" do
      it "should not deploy if the stack is not clear to deploy but forced however does not clear in time" do
        @status_mock.stub(:clear_for_deployment?) { false }
        @status_mock.should_receive(:clear_deployment_lock).
                     with(true)
        @deployment.execute(true).should be_false
      end

      it "should not deploy if the stack is not clear to deploy and not forced" do
        @status_mock.should_receive(:clear_deployment_lock).never
        @status_mock.stub :clear_for_deployment? => false
        @deployment.execute(false).should be_false
      end
    end
  end

  describe "get_artifact_endpoints" do
    before do
      @config_mock.stub(:artifacts) { ['chef_repo', 'cookbooks', 'app'] }
      @config_mock.should_receive(:artifact_deploy_variable).
                   with('chef_repo').and_return('CHEF_REPO_URL')
      @config_mock.should_receive(:artifact_deploy_variable).
                   with('app').and_return('APP_URL')
      @config_mock.should_receive(:artifact_deploy_variable).
                   with('cookbooks').and_return('COOKBOOKS_URL')
    end

    it "should create S3 endpoints" do
      endpoints = @deployment.send :get_artifact_endpoints

      endpoints['CHEF_REPO_URL'].should == 's3://chef_repo_bp-test-us-west-1/chef_repo_d/chef_repo.tar.gz'
      endpoints['APP_URL'].should == 's3://app_bp-test-us-west-1/app_d/app.tar.gz'
      endpoints['COOKBOOKS_URL'].should == 's3://cookbooks_bp-test-us-west-1/cookbooks_d/cookbooks.tar.gz'
    end

  end
end
