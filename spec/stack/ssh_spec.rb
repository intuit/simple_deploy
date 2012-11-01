require 'spec_helper'

describe SimpleDeploy::Stack::SSH do
  before do
    @stack_mock = mock 'stack'
    @task_mock = mock 'task'
    @config_mock = mock 'config'
    @logger_stub = stub 'logger', :debug => true,
                                  :info  => true,
                                  :error => true
    @config_mock.stub :logger => @logger_stub
    @config_mock.should_receive(:region).
                 with('test-env').
                 and_return 'test-us-west-1'
    @stack_mock.stub :attributes => { :ssh_gateway => false }
  end

  context "when unsuccessful" do
    it "should notify the user there are no running instances" do
      options = { :config      => @config_mock,
                  :instances   => [],
                  :environment => 'test-env',
                  :ssh_user    => 'user',
                  :ssh_key     => 'key',
                  :stack       => @stack_mock,
                  :name        => 'test-stack' }
      @ssh = SimpleDeploy::Stack::SSH.new options
      error = 'There are no running instances to execute this command.'
      expect { @ssh.execute(:sudo    => true,
                   :command => 'uname') }.to raise_error(RuntimeError, error)
 
    end
  end

  context "when successful" do
    before do
      options = { :config      => @config_mock,
                  :instances   => ['1.2.3.4', '4.3.2.1'],
                  :environment => 'test-env',
                  :ssh_user    => 'user',
                  :ssh_key     => 'key',
                  :stack       => @stack_mock,
                  :name        => 'test-stack' }
      @ssh = SimpleDeploy::Stack::SSH.new options
    end
  
    describe "when execute called" do
      before do
        task_logger_mock = mock 'task_logger'
        @ssh_options = Hash.new
        Capistrano::Configuration.should_receive(:new).
                                  with(:output => @logger_stub).
                                  and_return @task_mock
        @task_mock.stub :logger    => task_logger_mock,
                        :variables => @ssh_options
        task_logger_mock.should_receive(:level=).with(3)
        @task_mock.should_receive(:set).with :user, 'user'
        @task_mock.should_receive(:server).with('1.2.3.4', :instances)
        @task_mock.should_receive(:server).with('4.3.2.1', :instances)
      end

      describe "when succesful" do
        it "should execute a task with sudo" do
          @task_mock.should_receive(:load).with({:string=>"task :execute do\n          sudo 'uname'\n          end"})
          @task_mock.should_receive(:execute).and_return true
          @ssh.execute(:sudo    => true,
                       :command => 'uname').should be_true
        end

        it "should execute a task as the calling user " do
          @task_mock.should_receive(:load).with({:string=>"task :execute do\n          run 'uname'\n          end"})
          @task_mock.should_receive(:execute).and_return true
          @ssh.execute(:sudo    => false,
                       :command => 'uname').should be_true
        end
      end
      
      after do
          @ssh_options.should == { :ssh_options => { 
                                     :keys => 'key', :paranoid => false 
                                   }
                                 }
      end
    end
  end
end
