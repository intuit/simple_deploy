require 'spec_helper'

describe SimpleDeploy::AWS::CloudFormation::Error do
  include_context 'double stubbed config', :access_key => 'key',
                                           :secret_key => 'XXX',
                                           :region     => 'us-west-1'
  include_context 'double stubbed logger'

  before do
    @exception_stub1 = stub 'Fog::AWS::CloudFormation'
    @exception_stub1.stub(:message).and_return("No updates are to be performed.")

    @exception_stub2 = stub 'Fog::AWS::CloudFormation'
    @exception_stub2.stub(:message).and_return("Oops.")

    @exception_stub3 = stub 'Fog::AWS::CloudFormation'
    @exception_stub3.stub(:message).and_return("Stack:test does not exist")

    @exception_stub4 = stub 'Fog::AWS::CloudFormation::'
    @exception_stub4.stub(:message).and_return('')
  end

  describe 'process' do
    it 'should process no update messages' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub1
      expect { error.process }.to_not raise_error SimpleDeploy::Exceptions::CloudFormationError
    end

    it 'should raise an error if the exception is blank' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub4
      expect { error.process }.to raise_error SimpleDeploy::Exceptions::CloudFormationError
    end

    it 'should re-raise unknown errors as SimpleDeploy::CloudFormationError' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub2

      lambda { error.process }.should raise_error SimpleDeploy::Exceptions::CloudFormationError
    end

    it 'should re-raise unkonwn errors as SimpleDeploy::CloudFormationError and set mesg' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub2
      begin
        error.process
      rescue SimpleDeploy::Exceptions::CloudFormationError => e
        e.message.should == "Oops."
      end
    end

    it 'should reaise stck unkown messages as SimpleDeploy::UnknownStack' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub3
      lambda { error.process }.should raise_error SimpleDeploy::Exceptions::UnknownStack
    end

  end
end
