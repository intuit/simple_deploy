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
        @old_attributes = {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo'
        }
      end

      it 'should only filter attributes with camel case names' do
        new_attributes = subject.send(:filter_attributes, @old_attributes)

        new_attributes.has_key?('AmiId').should be_true
        new_attributes['AmiId'].should == 'ami-7b6a4e3e'
        new_attributes.has_key?('AppEnv').should be_true
        new_attributes['AppEnv'].should == 'pod-2-cd-1'
        new_attributes.has_key?('MaximumAppInstances').should be_true
        new_attributes['MaximumAppInstances'].should == 1
        new_attributes.has_key?('MinimumAppInstances').should be_true
        new_attributes['MinimumAppInstances'].should == 1
        new_attributes.has_key?('chef_repo_bucket_prefix').should_not be_true
        new_attributes.has_key?('chef_repo_domain').should_not be_true
      end

      it 'should replace the old stack name with the new stack name' do
        subject.instance_variable_set(:@opts, :new_name => 'new_stack')

        new_attributes = subject.send(:filter_attributes, 'Name' => 'old_stack')
        new_attributes['Name'].should == 'new_stack'
      end
    end

    context 'stack creation' do
      before do
        @config  = mock 'config'
        @logger  = stub 'logger'
        @options = { :environment => 'my_env',
                     :log_level   => 'debug',
                     :old_name    => 'old_stack',
                     :new_name    => 'new_stack',
                     :template    => 'my_template' }
        @old_stack   = stub :attributes => {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo'
        }
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
                                           :name        => 'old_stack').
                                      and_return(@old_stack)
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
                                      :required => [:environment, :old_name, :new_name, :template])
        Trollop.stub(:options).and_return(@options)

        @new_stack.should_receive(:create).with(:attributes => {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1}, :template => 'my_template')

        subject.clone
      end
    end
  end
end
