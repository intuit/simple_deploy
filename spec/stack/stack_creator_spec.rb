require 'spec_helper'
require 'json'

describe SimpleDeploy::StackCreator do
  include_context 'stubbed config'
  include_context 'double stubbed logger'

  before do
    @attributes = { "param1" => "value1", "param3" => "value3" }
    @template_json = '{ "Parameters": 
                        { 
                          "param1" : 
                            {
                              "Description" : "param-1"
                            },
                          "param2" : 
                            {
                              "Description" : "param-2"
                            }
                        }
                      }'
  end

  it "should map the attributes to a template's parameters and create a stack " do
    entry_mock = mock 'entry mock'
    file_mock = mock 'file mock'
    cloud_formation_mock = mock 'cloud formation mock'

    SimpleDeploy::AWS::CloudFormation.should_receive(:new).
                                      and_return cloud_formation_mock
    File.should_receive(:open).with('path_to_file').
                               and_return file_mock
    file_mock.should_receive(:read).and_return @template_json
    entry_mock.should_receive(:attributes).and_return @attributes
    cloud_formation_mock.should_receive(:create).
                         with(:name      => 'test-stack', 
                              :parameters => { 'param1' => 'value1' },
                              :template   => @template_json)
    stack_creator = SimpleDeploy::StackCreator.new :name          => 'test-stack',
                                                   :template_file => 'path_to_file',
                                                   :entry         => entry_mock

    stack_creator.create
  end

end
