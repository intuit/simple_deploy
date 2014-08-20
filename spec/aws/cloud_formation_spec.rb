require 'spec_helper'

describe SimpleDeploy::AWS::CloudFormation do
  include_context 'double stubbed logger'

  before do
    @error_stub = stub 'Error', :process => 'Processed Error'
    @response_stub = stub 'Excon::Response', :body => {
        'Stacks' => [{'StackStatus' => 'green', 'Outputs' => [{'key' => 'value'}]}],
        'StackResources' => [{'StackName' => 'my_stack'}],
        'StackEvents' => ['event1', 'event2'],
        'TemplateBody' => '{EIP: "string"}'
    }

    @args = {
      :parameters => { 'parameter1' => 'my_param' },
      :name => 'my_stack',
      :template => 'my_template'
    }

    @exception = Exception.new('Failed')
  end

  after do
    SimpleDeploy.release_config
  end

  describe 'temporary credentials' do
    include_context 'double stubbed config', :access_key => 'key',
                                             :secret_key => 'XXX',
                                             :security_token => 'the token',
                                             :temporary_credentials? => true,
                                             :region     => 'us-west-1'

    it 'creates a connection with the temporary credentials' do
      args = {
        aws_access_key_id: 'key',
        aws_secret_access_key: 'XXX',
        aws_session_token: 'the token',
        region: 'us-west-1'
      }
      Fog::AWS::CloudFormation.should_receive(:new).with(args)
      SimpleDeploy::AWS::CloudFormation.new
    end

  end

  describe 'with long lived credentials' do
    include_context 'double stubbed config', :access_key => 'key',
                                             :secret_key => 'XXX',
                                             :security_token => nil,
                                             :temporary_credentials? => false,
                                             :region     => 'us-west-1'
    before do
      @cf_mock = mock 'CloudFormation'
      Fog::AWS::CloudFormation.stub(:new).and_return(@cf_mock)

      @cf = SimpleDeploy::AWS::CloudFormation.new
    end

    describe "create" do
      it "should create the stack on Cloud Formation" do
        @cf_mock.should_receive(:create_stack).with('my_stack',
                                                    { 'Capabilities' => ['CAPABILITY_IAM'],
                                                      'TemplateBody' => 'my_template',
                                                      'Parameters' => { 'parameter1' => 'my_param' }
        })

        @cf.create(@args)
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:create_stack).with('my_stack',
                                                    { 'Capabilities' => ['CAPABILITY_IAM'],
                                                      'TemplateBody' => 'my_template',
                                                      'Parameters' => { 'parameter1' => 'my_param' }
        }).and_raise(@exception)

        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.create @args }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end

    describe "update" do
      it "should update the stack on Cloud Formation" do
        @cf_mock.should_receive(:update_stack).with('my_stack',
                                                    { 'Capabilities' => ['CAPABILITY_IAM'],
                                                      'TemplateBody' => 'my_template',
                                                      'Parameters' => { 'parameter1' => 'my_param' }
        })

        @cf.update(@args)
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:update_stack).with('my_stack',
                                                    { 'Capabilities' => ['CAPABILITY_IAM'],
                                                      'TemplateBody' => 'my_template',
                                                      'Parameters' => { 'parameter1' => 'my_param' }
        }).and_raise(@exception)
        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.update(@args) }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end


    describe 'destroy' do
      it "should delete the stack on Cloud Formation" do
        @cf_mock.should_receive(:delete_stack).with('my_stack')

        @cf.destroy('my_stack')
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:delete_stack).
          with('my_stack').
          and_raise @exception
        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.destroy('my_stack') }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end


    describe 'describe_stack' do
      it "should return the Cloud Formation description of the stack" do
        @cf_mock.should_receive(:describe_stacks).with('StackName' => 'my_stack').and_return(@response_stub)

        @cf.describe_stack('my_stack').should == [{'StackStatus' => 'green', 'Outputs' => [{'key' => 'value'}]}]
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:describe_stacks).
          with('StackName' => 'my_stack').
          and_raise @exception
        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.describe_stack('my_stack') }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end

    describe "stack_resources" do
      it "should return the Cloud Formation description of the stack resources" do
        @cf_mock.should_receive(:describe_stack_resources).with('StackName' => 'my_stack').and_return(@response_stub)

        @cf.stack_resources('my_stack').should == [{'StackName' => 'my_stack'}]
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:describe_stack_resources).
          with('StackName' => 'my_stack').
          and_raise @exception
        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.stack_resources('my_stack') }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end

    describe "stack_events" do
      it "should return the Cloud Formation description of the stack events" do
        @cf_mock.should_receive(:describe_stack_events).with('my_stack').and_return(@response_stub)

        @cf.stack_events('my_stack', 2).should == ['event1', 'event2']
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:describe_stack_events).
          with('my_stack').
          and_raise @exception

        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.stack_events('my_stack', 2) }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end

    describe "stack_status" do
      it "should return the Cloud Formation status of the stack" do
        @cf_mock.should_receive(:describe_stacks).with('StackName' => 'my_stack').and_return(@response_stub)

        @cf.stack_status('my_stack').should == 'green'
      end
    end

    describe "stack_outputs" do
      it "should return the Cloud Formation outputs for the stack" do
        @cf_mock.should_receive(:describe_stacks).with('StackName' => 'my_stack').and_return(@response_stub)

        @cf.stack_outputs('my_stack').should == [{'key' => 'value'}]
      end
    end

    describe "template" do
      it "should return the Cloud Formation template for the stack" do
        @cf_mock.should_receive(:get_template).with('my_stack').and_return(@response_stub)

        @cf.template('my_stack').should == '{EIP: "string"}'
      end

      it "should trap and re-raise exceptions as SimpleDeploy::Exceptions::CloudFormationError" do
        @cf_mock.should_receive(:get_template).
          with('my_stack').
          and_raise @exception
        SimpleDeploy::AWS::CloudFormation::Error.should_receive(:new).
          with(:exception => @exception).
          and_raise SimpleDeploy::Exceptions::CloudFormationError.new('failed')

        lambda { @cf.template('my_stack') }.
          should raise_error SimpleDeploy::Exceptions::CloudFormationError
      end
    end
  end

end
