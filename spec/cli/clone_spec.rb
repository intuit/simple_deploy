require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Clone do

  describe 'clone' do

    context 'camel case detection' do
      it "should correctly detect camel case attribute names" do
        subject.send(:is_camel_case?, 'Camelcase').should_not be_true 
        subject.send(:is_camel_case?, 'CamelCase').should be_true 
        subject.send(:is_camel_case?, 'camelCase').should be_true 
        subject.send(:is_camel_case?, 'camel case').should_not be_true 
        subject.send(:is_camel_case?, 'Camel Case').should_not be_true 
        subject.send(:is_camel_case?, 'Camel case').should_not be_true 
        subject.send(:is_camel_case?, 'CamelCaseLongUpper').should be_true 
        subject.send(:is_camel_case?, 'camelCaseLongLower').should be_true 
      end
    end

    context 'filter_attributes' do
      before do
        @source_attributes = {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo'
        }
      end

      it 'should only filter attributes with camel case names' do
        new_attributes = subject.send(:filter_attributes, @source_attributes)

        new_attributes.size.should == 4

        new_attributes[0].has_key?('AmiId').should be_true
        new_attributes[0]['AmiId'].should == 'ami-7b6a4e3e'
        new_attributes[1].has_key?('AppEnv').should be_true
        new_attributes[1]['AppEnv'].should == 'pod-2-cd-1'
        new_attributes[2].has_key?('MaximumAppInstances').should be_true
        new_attributes[2]['MaximumAppInstances'].should == 1
        new_attributes[3].has_key?('MinimumAppInstances').should be_true
        new_attributes[3]['MinimumAppInstances'].should == 1
      end
    end

    context 'stack creation' do
      before do
        @config  = mock 'config'
        @logger  = stub 'logger'
        @options = { :environment => 'my_env',
                     :log_level   => 'debug',
                     :source_name    => 'source_stack',
                     :new_name    => 'new_stack',
                     :template    => 'my_template' }
        @source_stack   = stub :attributes => {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo'
        }, :template => { 'foo' => 'bah' }
        @new_stack   = stub :attributes => {}

        SimpleDeploy::Config.stub(:new).and_return(@config)
        @config.should_receive(:environment).with('my_env').and_return(@config)
        SimpleDeploy::SimpleDeployLogger.should_receive(:new).
                                  with(:log_level => 'debug').
                                  and_return(@logger)

        SimpleDeploy::Stack.should_receive(:new).
                                      with(:config      => @config,
                                           :environment => 'my_env',
                                           :logger      => @logger,
                                           :name        => 'source_stack').
                                      and_return(@source_stack)
        SimpleDeploy::Stack.should_receive(:new).
                                      with(:config      => @config,
                                           :environment => 'my_env',
                                           :logger      => @logger,
                                           :name        => 'new_stack').
                                      and_return(@new_stack)
      end
      
      it 'should create the new stack using the filtered attributes' do
        SimpleDeploy::CLI::Shared.should_receive(:valid_options?).
                                 with(:provided => @options,
                                      :required => [:environment, :source_name, :new_name, :template])
        Trollop.stub(:options).and_return(@options)

        @new_stack.should_receive(:create) do |options|
          options[:attributes].should == [{ 'AmiId' => 'ami-7b6a4e3e' },
                                          { 'AppEnv' => 'pod-2-cd-1' },
                                          { 'MaximumAppInstances' => 1 },
                                          { 'MinimumAppInstances' => 1 }]
          options[:template].should match /new_stack_template.json/
        end

        subject.clone
      end
    end
  end
end
