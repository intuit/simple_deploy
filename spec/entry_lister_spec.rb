require 'spec_helper'

describe SimpleDeploy::EntryLister do
  include_context 'stubbed config'

  it "should create a list of entries" do
    @simple_db_mock = mock 'simple db'
    SimpleDeploy::AWS::SimpleDB.should_receive(:new).and_return @simple_db_mock
    @simple_db_mock.should_receive(:domain_exists?).
                    with("stacks").
                    and_return true
    @simple_db_mock.should_receive(:select).
                    with("select * from stacks").
                    and_return('stack-to-find-us-west-1' => { 'attr1' => 'value1' })
    entry_lister = SimpleDeploy::EntryLister.new
    entry_lister.all.should == ['stack-to-find']
  end

  it "should return a blank array if the domain does not exist" do
    @simple_db_mock = mock 'simple db'
    SimpleDeploy::AWS::SimpleDB.should_receive(:new).and_return @simple_db_mock
    @simple_db_mock.should_receive(:domain_exists?).
                    with("stacks").
                    and_return false
    @simple_db_mock.should_receive(:select).
                    with("select * from stacks").exactly(0).times
    entry_lister = SimpleDeploy::EntryLister.new
    entry_lister.all.should == []
  end

end
