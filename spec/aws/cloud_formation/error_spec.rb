require 'spec_helper'

describe SimpleDeploy::AWS::CloudFormation::Error do
  before do
    #@logger_stub = stub 'logger stub', :info => 'true', :warn => 'true'
    @logger_mock = mock 'Logger'
    @config_stub = stub 'Config', :logger => @logger_mock, :access_key => 'key', :secret_key => 'XXX', :region => 'us-west1'

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
      @logger_mock.should_receive(:info).with('No updates are to be performed.')

      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub1,
                                                           :logger    => @logger_mock
      error.process
    end

    it 'should re-raise unkonwn errors as SimpleDeploy::CloudFormationError' do
      @logger_mock.should_receive(:error).with('Oops.')

      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub2,
                                                           :logger    => @logger_mock

      lambda { error.process }.should raise_error SimpleDeploy::Exceptions::CloudFormationError
    end

    it 'should re-raise unkonwn errors as SimpleDeploy::CloudFormationError and set mesg' do
      @logger_mock.should_receive(:error).with('Oops.')

      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub2,
                                                           :logger    => @logger_mock
      begin
        error.process
      rescue SimpleDeploy::Exceptions::CloudFormationError => e
        e.message.should == "Oops."
      end
    end

    it 'should reaise stck unkown messages as SimpleDeploy::UnknownStack' do
      @logger_mock.should_receive(:error).with('Stack:test does not exist')

      error = SimpleDeploy::AWS::CloudFormation::Error.new :exception => @exception_stub3,
                                                           :logger    => @logger_mock
      lambda { error.process }.should raise_error SimpleDeploy::Exceptions::UnknownStack
    end

  end
end
