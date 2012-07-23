require 'spec_helper'

describe SimpleDeploy do

  describe "with all required configurations" do
    before do
      config = { 'campfire' => { 'token' => 'tkn' } }
                
      @config_mock = mock 'config mock'
      @stack_mock = mock 'stack'
      @logger_mock = mock 'logger mock'
      @tinder_mock = mock 'tinder'
      @config_mock.should_receive(:logger).and_return @logger_mock
      @config_mock.should_receive(:notifications).and_return config
      @config_mock.should_receive(:environment).and_return 'env_config'
      Stackster::Stack.should_receive(:new).
                       with(:environment => 'test',
                            :name        => 'stack_name',
                            :config      => 'env_config',
                            :logger      => @logger_mock).
                       and_return @stack_mock

      Tinder::Campfire.should_receive(:new).
                       with('subdom', :token => 'tkn').and_return @tinder_mock
      @stack_mock.should_receive(:attributes).
                  and_return( 'campfire_room_ids'  => '1,2',
                              'campfire_subdomain' => 'subdom' )
      @logger_mock.should_receive(:debug).
                   with "Campfire subdomain 'subdom'."
      @logger_mock.should_receive(:debug).
                   with "Campfire room ids '1,2'."
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test',
                                                       :config      => @config_mock

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
      @logger_mock.should_receive(:debug).
                   with "Campfire notifications complete."
      room1_mock.should_receive(:speak).with :message => "heh you guys!"
      room2_mock.should_receive(:speak).with :message => "heh you guys!"
      @campfire.send(:message => 'heh you guys!')
    end
  end

  describe "without valid attributes" do
    before do
      config = { 'campfire' => { 'token' => 'tkn' } }
                
      @config_mock = mock 'config mock'
      @stack_mock = mock 'stack'
      @logger_mock = mock 'logger mock'
      @tinder_mock = mock 'tinder'
      @config_mock.should_receive(:logger).and_return @logger_mock
      @config_mock.should_receive(:notifications).and_return config
      @config_mock.should_receive(:environment).and_return 'env_config'
      Stackster::Stack.should_receive(:new).
                       with(:environment => 'test',
                            :name        => 'stack_name',
                            :config      => 'env_config',
                            :logger      => @logger_mock).
                       and_return @stack_mock

      Tinder::Campfire.should_receive(:new).
                       with(nil, :token => 'tkn').and_return @tinder_mock
      @stack_mock.should_receive(:attributes).
                  and_return({})
      @logger_mock.should_receive(:debug).
                   with "Campfire subdomain ''."
      @logger_mock.should_receive(:debug).
                   with "Campfire room ids ''."
      @logger_mock.should_receive(:debug).
                   with "Campfire notifications complete."
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test',
                                                       :config      => @config_mock
    end

    it "should not blow up if campfire_subdom & campfire_room_ids are not present" do
      @campfire.send(:message => 'heh you guys!')
    end
  end

end

