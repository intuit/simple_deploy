require 'spec_helper'

describe SimpleDeploy do

  before do
    @attributes = { 'key'         => 'val',
                    'ssh_gateway' => '1.2.3.4',
                    'chef_repo' => 'chef_repo',
                    'chef_repo_bucket_prefix' => 'chef_repo_bp',
                    'chef_repo_domain' => 'chef_repo_d',
                    'app' => 'app',
                    'app_bucket_prefix' => 'app_bp',
                    'app_domain' => 'app_d',
                    'cookbooks' => 'cookbooks',
                    'cookbooks_bucket_prefix' => 'cookbooks_bp',
                    'cookbooks_domain' => 'cookbooks_d' }
    @logger_stub = stub 'logger stub'
    @logger_stub.stub :debug => 'true', :info => 'true'

    @config_mock = mock 'config mock'
    @config_mock.stub(:logger) { @logger_stub }
    @config_mock.stub(:region) { 'test-us-west-1' }

    @stack_mock = mock 'stack mock'
    @stack_mock.stub(:attributes) { @attributes }

    options = { :config      => @config_mock,
                :instances   => ['1.2.3.4', '4.3.2.1'],
                :environment => 'test-us-west-1',
                :ssh_user    => 'user',
                :ssh_key     => 'key',
                :stack       => @stack_mock,
                :name        => 'stack-name' }
    @stack = SimpleDeploy::Stack::Deployment.new options
  end

  it "should not blow up creating a new deployment" do
    @stack.class.should == SimpleDeploy::Stack::Deployment
  end

  describe "creating a deploy" do
    it "should gracefully tell the user there are no running instances" do
      options = { :config      => @config_mock,
                 :instances   => [],
                 :environment => 'test-us-west-1',
                 :ssh_user    => 'user',
                 :ssh_key     => 'key',
                 :stack       => @stack_mock,
                 :name        => 'stack-name' }
      stack = SimpleDeploy::Stack::Deployment.new options

      expect {
        stack.create_deployment
      }.to raise_error(RuntimeError, 'There are no running instances to deploy to')
    end
  end

  describe "executing a deploy" do
    before do
      @deployment_mock = mock 'cap config'
      @variables_mock = mock 'variables mock'
      @artifact_mock = mock 'artifact mock'
      level_stub = stub 'level'
      level_stub.should_receive(:level=).with(3)
      Capistrano::Configuration.should_receive(:new).and_return @deployment_mock
      @deployment_mock.should_receive(:logger).and_return level_stub
      @deployment_mock.should_receive(:set).with :gateway, '1.2.3.4'
      @deployment_mock.should_receive(:set).with :user, 'user'
      @deployment_mock.should_receive(:variables).and_return @variables_mock
      @variables_mock.should_receive(:[]=).
                      with :ssh_options, ( { :keys     => 'key',
                                             :paranoid => false } )
      @deployment_mock.should_receive(:server).with '1.2.3.4', :instances
      @deployment_mock.should_receive(:server).with '4.3.2.1', :instances
      @config_mock.should_receive(:artifacts).
                   and_return ['cookbooks']
      @config_mock.should_receive(:artifact_deploy_variable).with('cookbooks').
                   and_return 'deploy_var'
      SimpleDeploy::Artifact.should_receive(:new).and_return @artifact_mock
      @artifact_mock.should_receive(:endpoints).
                     and_return('s3' => 's3://bucket/dir/key')
      @stack_mock.should_receive(:instances).exactly(2).times.
                  and_return [ { 'instancesSet' => 
                                 [ { 'privateIpAddress' => '10.1.2.3' } ] } ]
      @config_mock.should_receive(:deploy_script).and_return 'script.sh'
      @deployment_mock.should_receive(:load).with({:string=>"task :simpledeploy do\n        sudo 'env deploy_var=s3://bucket/dir/key PRIMARY_HOST=10.1.2.3 script.sh'\n        end"}).and_return true
      @stack.create_deployment
    end

    it "should deploy if the stack is clear to deploy" do
      status_mock = mock 'status mock'
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              and_return status_mock
      status_mock.stub(:clear_for_deployment?).and_return true
      status_mock.should_receive(:set_deployment_in_progress)
      @deployment_mock.should_receive(:simpledeploy)
      status_mock.should_receive(:unset_deployment_in_progress)

      @stack.execute.should == true
    end

    it "should deploy if the stack is not clear to deploy but forced" do
      status_mock = mock 'status mock'
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              and_return status_mock
      status_mock.should_receive(:clear_for_deployment?).and_return false, true
      status_mock.should_receive(:clear_deployment_lock).with(true)
      status_mock.should_receive(:set_deployment_in_progress)
      @deployment_mock.should_receive(:simpledeploy)
      status_mock.should_receive(:unset_deployment_in_progress)

      @stack.execute(true).should == true
    end

    it "should not deploy if the stack is not clear to deploy and not forced" do
      status_mock = mock 'status mock'
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              and_return status_mock
      status_mock.stub(:clear_for_deployment?).and_return false
      @logger_stub.should_receive(:error)

      @stack.execute.should == false
    end
  end

  describe "get_artifact_endpoints" do
    before do
      @config_mock.stub(:artifacts) { ['chef_repo', 'cookbooks', 'app'] }
      @config_mock.should_receive(:artifact_deploy_variable).with('chef_repo').and_return('CHEF_REPO_URL')
      @config_mock.should_receive(:artifact_deploy_variable).with('app').and_return('APP_URL')
      @config_mock.should_receive(:artifact_deploy_variable).with('cookbooks').and_return('COOKBOOKS_URL')
    end

    it "should create S3 endpoints" do
      endpoints = @stack.send :get_artifact_endpoints

      endpoints['CHEF_REPO_URL'].should == 's3://chef_repo_bp-test-us-west-1/chef_repo_d/chef_repo.tar.gz'
      endpoints['APP_URL'].should == 's3://app_bp-test-us-west-1/app_d/app.tar.gz'
      endpoints['COOKBOOKS_URL'].should == 's3://cookbooks_bp-test-us-west-1/cookbooks_d/cookbooks.tar.gz'
    end
  end
end
