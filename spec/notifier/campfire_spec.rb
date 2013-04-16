require 'spec_helper'

describe SimpleDeploy::Notifier::Campfire do
  include_context 'stubbed config'
  include_context 'double stubbed logger'
  include_context 'stubbed stack', :name        => 'my_stack',
                                   :environment => 'my_env'

  describe "with all required configurations" do
    before do
      config = { 'campfire' => { 'token' => 'tkn' } }
                
      @tinder_mock = mock 'tinder'

      @config_mock.should_receive(:notifications).and_return config

      Tinder::Campfire.should_receive(:new).
                       with("subdom", { :token=>"tkn", :ssl_options=> { :verify => false } }).and_return @tinder_mock
      @stack_mock.should_receive(:attributes).
                  and_return( 'campfire_room_ids'  => '1,2',
                              'campfire_subdomain' => 'subdom' )
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test'

    end

    it "should send a message to campfire rooms" do
      room1_mock = mock 'tinder'
      room2_mock = mock 'tinder'
      @tinder_mock.should_receive(:find_room_by_id).with(1).
                                                    and_return room1_mock
      @tinder_mock.should_receive(:find_room_by_id).with(2).
                                                    and_return room2_mock
      room1_mock.should_receive(:speak).with :message => "heh you guys!"
      room2_mock.should_receive(:speak).with :message => "heh you guys!"
      @campfire.send(:message => 'heh you guys!')
    end
  end

  describe "without valid attributes" do
    before do
      config = nil
                
      @tinder_mock = mock 'tinder'

      @stack_mock.should_receive(:attributes).
                  and_return({})
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test'
    end

    it "should not blow up if campfire_subdom & campfire_room_ids are not present" do
      @campfire.send(:message => 'heh you guys!')
    end
  end

end

