require 'spec_helper'

describe SimpleDeploy::AWS::CloudFormation::Error do
  include_context 'double stubbed config', :access_key => 'key',
                                           :secret_key => 'XXX',
                                           :region     => 'us-west-1'
  include_context 'double stubbed logger'

  before do
    @config_stub = stub 'Config', :access_key => 'key', :secret_key => 'XXX', :region => 'us-west1'

    @exception_stub1 = stub 'Excon::Response'
    @exception_stub1.stub(:response).and_return(@exception_stub1)
    @exception_stub1.stub(:body).and_return('<opt><Error><Message>No updates are to be performed.</Message></Error></opt>')

    @exception_stub2 = stub 'Excon::Response'
    @exception_stub2.stub(:response).and_return(@exception_stub2)
    @exception_stub2.stub(:body).and_return('<opt><Error><Message>Oops.</Message></Error></opt>')

    @exception_stub3 = stub 'Excon::Response'
    @exception_stub3.stub(:response).and_return(@exception_stub3)
    @exception_stub3.stub(:body).and_return('<opt><Error><Message>Stack:test does not exist</Message></Error></opt>')
  end

  describe 'process' do
    it 'should process no update messages' do
      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub1
      expect { error.process }.to_not raise_error SimpleDeploy::Exceptions::CloudFormationError
    end

    it 'should re-raise unkonwn errors as SimpleDeploy::CloudFormationError' do
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
