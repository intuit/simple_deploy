require 'spec_helper'

class TestObj
  include SimpleDeploy::AWS::Helpers
  attr_accessor :config
end

describe SimpleDeploy::AWS::Helpers do

  describe 'connection_args' do
    before do
      @config = stub 'config',
                     access_key: 'key',
                     secret_key: 'XXX',
                     region:     'us-west-1'
      @obj = TestObj.new

      @args = {
        aws_access_key_id:     'key',
        aws_secret_access_key: 'XXX',
        region:                'us-west-1'
      }
    end

    describe 'with long lived credentials' do
      before do
        @config.stub temporary_credentials?: false
        @obj.config = @config
      end

      it 'does not include session token' do
        @obj.connection_args.should eq @args
      end
    end

    describe 'with temporary credentials' do
      before do
        @config.stub session_token: 'token'
        @config.stub temporary_credentials?: true
        @obj.config = @config
      end

      it 'includes session session token' do
        args = @args.merge({aws_session_token: 'token'})
        @obj.connection_args.should eq args
      end
    end

  end

end
