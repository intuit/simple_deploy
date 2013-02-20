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
    @options = { :config      => @config_mock,
                 :instances   => ['1.2.3.4', '4.3.2.1'],
                 :environment => 'test-env',
                 :ssh_user    => 'user',
                 :ssh_key     => 'key',
                 :stack       => @stack_mock,
                 :name        => 'test-stack' }
    @task_logger_mock = mock 'task_logger'
    @ssh_options = Hash.new
    @task_mock.stub :logger    => @task_logger_mock,
                    :variables => @ssh_options
  end

  context "when unsuccessful" do
    it "should return false when no running instances running" do
      @ssh = SimpleDeploy::Stack::SSH.new @options.merge({ :instances   => [] })

      @ssh.execute(:sudo    => true, :command => 'uname').should be_false
    end

    context "with capistrano configured" do
      before do
        Capistrano::Configuration.should_receive(:new).
            with(:output => @logger_stub).
            and_return @task_mock

        @task_logger_mock.should_receive(:level=).with(3)
        @task_mock.should_receive(:set).with :user, 'user'
        @task_mock.should_receive(:server).with('1.2.3.4', :instances)
        @task_mock.should_receive(:server).with('4.3.2.1', :instances)
      end

      it "should return false when Capistrano command error" do
        @ssh = SimpleDeploy::Stack::SSH.new @options

        @task_mock.should_receive(:load).with({ :string=>"task :execute do\n          sudo 'a_bad_command'\n          end" })
        @task_mock.should_receive(:execute).and_raise Capistrano::CommandError.new 'command error'

        @ssh.execute(:sudo => true, :command => 'a_bad_command').should be_false
      end

      it "should return false when Capistrano connection error" do
        @ssh = SimpleDeploy::Stack::SSH.new @options

        @task_mock.stub :logger    => @task_logger_mock,
                        :variables => @ssh_options
        @task_mock.should_receive(:load).with({ :string=>"task :execute do\n          sudo 'uname'\n          end" })
        @task_mock.should_receive(:execute).and_raise Capistrano::ConnectionError.new 'connection error'

        @ssh.execute(:sudo => true, :command => 'uname').should be_false
      end

      it "should return false when Capistrano generic error" do
        @ssh = SimpleDeploy::Stack::SSH.new @options

        @task_mock.should_receive(:load).with({ :string=>"task :execute do\n          sudo 'uname'\n          end" })
        @task_mock.should_receive(:execute).and_raise Capistrano::Error.new 'generic error'

        @ssh.execute(:sudo => true, :command => 'uname').should be_false
      end
    end
  end

  context "when successful" do
    before do
      @ssh = SimpleDeploy::Stack::SSH.new @options
    end

    describe "when execute called" do
      before do
        Capistrano::Configuration.should_receive(:new).
            with(:output => @logger_stub).
            and_return @task_mock

        @task_logger_mock.should_receive(:level=).with(3)
        @task_mock.should_receive(:set).with :user, 'user'
        @task_mock.should_receive(:server).with('1.2.3.4', :instances)
        @task_mock.should_receive(:server).with('4.3.2.1', :instances)
      end

      describe "when successful" do
        it "should execute a task with sudo" do
          @task_mock.should_receive(:load).with({ :string=>"task :execute do\n          sudo 'uname'\n          end" })
          @task_mock.should_receive(:execute).and_return true

          @ssh.execute(:sudo    => true,
                       :command => 'uname').should be_true
        end

        it "should execute a task as the calling user " do
          @task_mock.should_receive(:load).with({ :string=>"task :execute do\n          run 'uname'\n          end" })
          @task_mock.should_receive(:execute).and_return true

          @ssh.execute(:sudo    => false,
                       :command => 'uname').should be_true
        end
      end

      after do
        @ssh_options.should == { :ssh_options => { :keys => 'key',
                                                   :paranoid => false } }
      end
    end
  end
end
