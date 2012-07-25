require 'spec_helper'

describe SimpleDeploy do

  describe "A stack" do
    
    before do
      @config_mock = mock 'config mock'
      @logger_mock = mock 'logger mock'
      @config_mock.should_receive(:logger).and_return @logger_mock
      SimpleDeploy::Config.should_receive(:new).
                           with(:logger => 'my-logger').
                           and_return @config_mock
      @stack = SimpleDeploy::Stack.new :environment => 'test-env',
                                       :name        => 'test-stack',
                                       :logger      => 'my-logger',
                                       :config      => @config_mock
    end

    it "should call create stack" do
      saf_mock = mock 'stack attribute formater mock'
      stack_mock = mock 'stackster stack mock'
      environment_config_mock = mock 'environment config mock'
      @config_mock.should_receive(:environment).with('test-env').
                   and_return environment_config_mock
      SimpleDeploy::StackAttributeFormater.should_receive(:new).
                                           with(:config      => @config_mock,
                                                :environment => 'test-env').
                                           and_return saf_mock
      Stackster::Stack.should_receive(:new).with(:environment => 'test-env',
                                                 :name        => 'test-stack',
                                                 :config      => environment_config_mock,
                                                 :logger      => @logger_mock).
                                            and_return stack_mock
      saf_mock.should_receive(:updated_attributes).with({'arg1' => 'val'}).
               and_return('arg1' => 'new_val')
      stack_mock.should_receive(:create).with :attributes => { 'arg1' => 'new_val' },
                                              :template   => 'some_json'
      @stack.create(:attributes => { 'arg1' => 'val' }, 
                    :template => 'some_json')
    end

  end
end
