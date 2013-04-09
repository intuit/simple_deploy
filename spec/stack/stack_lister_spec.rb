require 'spec_helper'

describe SimpleDeploy::StackLister do

  it "should list the stack entries" do
    config_mock = mock 'config mock'
    entry_lister_mock = mock 'entry lister mock'
    resource_manager = SimpleDeploy::ResourceManager.instance
    resource_manager.should_receive(:config).and_return(config_mock)

    SimpleDeploy::EntryLister.should_receive(:new).
                              and_return entry_lister_mock
    entry_lister_mock.should_receive(:all)
                         
    stack_lister = SimpleDeploy::StackLister.new
    stack_lister.all
  end

end
