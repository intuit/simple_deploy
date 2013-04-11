require 'spec_helper'

describe SimpleDeploy::Notifier::Campfire do
  include_context 'stubbed config'

  describe "with all required configurations" do
    before do
      config = { 'campfire' => { 'token' => 'tkn' } }
                
      @stack_mock = mock 'stack'
      @logger_mock = mock 'logger mock'
      @tinder_mock = mock 'tinder'

      @config_mock.should_receive(:notifications).and_return config

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'test',
                               :name        => 'stack_name',
                               :logger      => @logger_mock).
                          and_return @stack_mock

      Tinder::Campfire.should_receive(:new).
                       with("subdom", { :token=>"tkn", :ssl_options=> { :verify => false } }).and_return @tinder_mock
      @stack_mock.should_receive(:attributes).
                  and_return( 'campfire_room_ids'  => '1,2',
                              'campfire_subdomain' => 'subdom' )
      @logger_mock.should_receive(:debug).
                   with "Campfire subdomain 'subdom'."
      @logger_mock.should_receive(:debug).
                   with "Campfire room ids '1,2'."
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test',
                                                       :logger      => @logger_mock

    end

    it "should send a message to campfire rooms" do
      room1_mock = mock 'tinder'
      room2_mock = mock 'tinder'
      @tinder_mock.should_receive(:find_room_by_id).with(1).
                                                    and_return room1_mock
      @tinder_mock.should_receive(:find_room_by_id).with(2).
                                                    and_return room2_mock
      @logger_mock.should_receive(:debug).
                   with "Sending notification to Campfire room 1."
      @logger_mock.should_receive(:debug).
                   with "Sending notification to Campfire room 2."
      @logger_mock.should_receive(:info).
                   with "Sending Campfire notifications."
      @logger_mock.should_receive(:info).
                   with "Campfire notifications complete."
      room1_mock.should_receive(:speak).with :message => "heh you guys!"
      room2_mock.should_receive(:speak).with :message => "heh you guys!"
      @campfire.send(:message => 'heh you guys!')
    end
  end

  describe "without valid attributes" do
    before do
      config = nil
                
      @stack_mock = mock 'stack'
      @logger_mock = mock 'logger mock'
      @tinder_mock = mock 'tinder'

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'test',
                               :name        => 'stack_name',
                               :logger      => @logger_mock).
                          and_return @stack_mock

      @stack_mock.should_receive(:attributes).
                  and_return({})
      @logger_mock.should_receive(:debug).
                   with "Campfire subdomain ''."
      @logger_mock.should_receive(:debug).
                   with "Campfire room ids ''."
      @logger_mock.should_receive(:info).
                   with "Sending Campfire notifications."
      @logger_mock.should_receive(:info).
                   with "Campfire notifications complete."
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test',
                                                       :logger      => @logger_mock
    end

    it "should not blow up if campfire_subdom & campfire_room_ids are not present" do
      @campfire.send(:message => 'heh you guys!')
    end
  end

end

