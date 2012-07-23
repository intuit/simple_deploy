require 'spec_helper'

describe SimpleDeploy do

  before do
    config = { 'campfire' =>
               { 'token'     => 'tkn',
                 'subdomain' => 'subdom',
                 'room_ids'  => ['1', '2']
               }
             }
              
    @config_mock = mock 'config mock'
    @logger_mock = mock 'logger mock'
    @tinder_mock = mock 'tinder'
    @config_mock.should_receive(:logger).and_return @logger_mock
    @config_mock.should_receive(:notifications).and_return config
    Tinder::Campfire.should_receive(:new).
                     with('subdom', :token => 'tkn').and_return @tinder_mock
    @campfire = SimpleDeploy::Notifier::Campfire.new :stack_name  => 'stack_name',
                                                     :environment => 'test',
                                                     :config      => @config_mock

  end

  it "should send a message to campfire rooms" do
    room1_mock = mock 'tinder'
    room2_mock = mock 'tinder'
    @tinder_mock.should_receive(:find_room_by_id).with('1').
                                                  and_return room1_mock
    @tinder_mock.should_receive(:find_room_by_id).with('2').
                                                  and_return room2_mock
    room1_mock.should_receive(:speak).with :message => "heh you guys!"
    room2_mock.should_receive(:speak).with :message => "heh you guys!"
    @campfire.send(:message => 'heh you guys!').should be_true
  end

end

