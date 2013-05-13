require 'spec_helper'

describe SimpleDeploy::Notifier::Campfire do
  include_context 'stubbed config'
  include_context 'double stubbed logger'
  include_context 'stubbed stack', :name        => 'my_stack',
                                   :environment => 'my_env'

  before do
    @comms_mock = mock 'Campfire communications'

    @room1_mock = mock 'Esbit room1', :id => 1, :name => 'Room 1'
    @room2_mock = mock 'Esbit room2', :id => 2, :name => 'Room 2'
    @comms_mock.stub(:rooms).and_return([@room1_mock, @room2_mock])
  end

  describe "with all required configurations" do
    before do
      config = { 'campfire' => { 'token' => 'tkn' } }
      @config_mock.should_receive(:notifications).and_return config

      Esbit::Campfire.should_receive(:new).with("subdom", "tkn").
                      and_return @comms_mock
      @stack_mock.should_receive(:attributes).
                  and_return( 'campfire_room_ids'  => '1,2',
                              'campfire_subdomain' => 'subdom' )
      @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                       :environment => 'test'

    end

    it "should send a message to campfire rooms" do

      @room1_mock.should_receive(:say).with :message => "heh you guys!"
      @room2_mock.should_receive(:say).with :message => "heh you guys!"

      @campfire.send(:message => 'heh you guys!')
    end
  end

  describe "without valid attributes" do
    before do
      config = nil
                
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

