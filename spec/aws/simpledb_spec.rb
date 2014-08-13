require 'spec_helper'

describe SimpleDeploy::AWS::SimpleDB do
  include_context 'double stubbed config', :access_key => 'key',
                                           :secret_key => 'XXX',
                                           :region     => 'us-west-1'

  before do
    @response_stub = stub 'Excon::Response', :body => {
      'RequestId' => 'rid',
      'Domains' => ['domain1', 'domain2'],
      'Items' => { 'item1' => { 'key' => ['value'] } },
      'NextToken' => nil
    }
    @multi_response_stub = stub 'Excon::Response', :body => {
      'RequestId' => 'rid',
      'Domains' => ['domain1', 'domain2'],
      'Items' => { 'item1-2' => { 'key' => ['value'] } },
      'NextToken' => 'Chunk2'
    }
  end

  describe 'temporary credentials' do
    include_context 'double stubbed config', :access_key => 'key',
                                             :secret_key => 'XXX',
                                             :session_token => 'the token',
                                             :temporary_credentials? => true,
                                             :region     => 'us-west-1'

    it 'creates a connection with the temporary credentials' do
      args = {
        aws_access_key_id: 'key',
        aws_secret_access_key: 'XXX',
        aws_session_token: 'the token',
        region: 'us-west-1'
      }
      Fog::AWS::SimpleDB.should_receive(:new).with(args)
      SimpleDeploy::AWS::SimpleDB.new
    end
  end

  describe 'with long lived credentials' do
    include_context 'double stubbed config', :access_key => 'key',
                                             :secret_key => 'XXX',
                                             :session_token => nil,
                                             :temporary_credentials? => false,
                                             :region     => 'us-west-1'
    before do
      @db_mock = mock 'SimpleDB'
      Fog::AWS::SimpleDB.stub(:new).and_return(@db_mock)
      @db_mock.stub(:list_domains).and_return(@response_stub)

      @db = SimpleDeploy::AWS::SimpleDB.new
    end

    describe 'domains' do
      it 'should return a list of domains' do
        @db.domains.should == ['domain1', 'domain2']
      end
    end

    describe 'domain_exists?' do
      it 'should return true for existing domains' do
        @db.domain_exists?('domain1').should be_true
      end

      it 'should return false for non-existent domains' do
        @db.domain_exists?('baddomain1').should_not be_true
      end
    end

    describe 'create_domain' do
      it 'should create a new domain' do
        @db_mock.should_receive(:create_domain).with('newdomain').and_return(@response_stub)

        @db.create_domain('newdomain').body['RequestId'].should == 'rid'
      end

      it 'should not create a duplicate domain' do
        @db_mock.should_not_receive(:create_domain)

        @db.create_domain('domain1').should be_nil
      end
    end

    describe 'put_attributes' do
      it 'should update the specified domain' do
        @db_mock.should_receive(:put_attributes).with('domain1', 'item1', { 'key' => 'value' }, {}).and_return(@response_stub)

        @db.put_attributes('domain1', 'item1', { 'key' => 'value' }, {}).body['RequestId'].should == 'rid'
      end
    end

    describe 'select' do
      it 'should return query items' do
        @db_mock.should_receive(:select).with('item1', { "ConsistentRead" => true, "NextToken" => nil } ).and_return(@response_stub)

        @db.select('item1').should == { 'item1' => { 'key' => ['value'] } }
      end

      it 'should return multiple chunks of query items' do
        @db_mock.should_receive(:select).with('item1', { "ConsistentRead" => true, "NextToken" => nil } ).and_return(@multi_response_stub)
        @db_mock.should_receive(:select).with('item1', { "ConsistentRead" => true, "NextToken" => 'Chunk2' } ).and_return(@response_stub)

        @db.select('item1').should == { 'item1' => { 'key' => ['value'] }, 'item1-2' => { 'key' => ['value'] } }
      end
    end

    describe 'delete' do
      it 'should delete the attributes identified by domain and key' do
        @db_mock.should_receive(:delete_attributes).with('domain1', 'item1').and_return(@response_stub)

        @db.delete('domain1', 'item1').body['RequestId'].should == 'rid'
      end
    end

    describe 'delete_items' do
      it 'should delete the specific attributes passed associated with domain and key' do
        @db_mock.should_receive(:delete_attributes).with('domain1', 'item1', {'value'=>nil}).and_return(@response_stub)

        @db.delete_items('domain1', 'item1', {'value'=>nil}).body['RequestId'].should == 'rid'
      end
    end
  end
end
