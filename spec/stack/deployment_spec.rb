require 'spec_helper'

describe SimpleDeploy do

  before do
    @attributes = { 'key'         => 'val',
                    'ssh_gateway' => '1.2.3.4' }
    @config_mock = mock 'config mock'
    @logger_stub = stub 'logger stub'
    @logger_stub.stub :debug => 'true', :info => 'true'
    @stack_mock = mock 'stack mock'

    @stack_mock.should_receive(:attributes).and_return @attributes
    @config_mock.should_receive(:logger).and_return @logger_stub
    @config_mock.should_receive(:region).with('test-us-west-1').
                                         and_return 'us-west-1'

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
      @config_mock.should_receive(:artifact_bucket_prefix).with('cookbooks').
                   and_return 'bucket_prefix'
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
      status_mock.should_receive(:clear_for_deployment?).and_return true
      status_mock.should_receive(:set_deployment_in_progress)
      @deployment_mock.should_receive(:simpledeploy)
      status_mock.should_receive(:unset_deployment_in_progress)
      @stack.execute.should == true
    end

    it "should deploy if the stack is not clear to deploy but forced" do
      status_mock = mock 'status mock'
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              and_return status_mock
      status_mock.should_receive(:clear_for_deployment?).and_return true
      status_mock.should_receive(:set_deployment_in_progress)
      @deployment_mock.should_receive(:simpledeploy)
      status_mock.should_receive(:unset_deployment_in_progress)
      @stack.execute(true).should == true
    end

    it "should deploy if the stack is not clear to deploy but forced" do
      status_mock = mock 'status mock'
      SimpleDeploy::Stack::Deployment::Status.should_receive(:new).
                                              and_return status_mock
      status_mock.should_receive(:clear_for_deployment?).and_return false
      @logger_stub.should_receive(:error)
      @stack.execute.should == false
    end
  end

end
