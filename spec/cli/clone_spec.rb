require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Clone do
  include_context 'cli config'
  include_context 'double stubbed logger'
  include_context 'clone stack pair', :source_name => 'source_stack',
                                      :source_env  => 'my_env',
                                      :new_name    => 'new_stack',
                                      :new_env     => 'my_env'

  describe 'clone' do
    context 'filter_attributes' do
      before do
        @source_attributes = {
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo',
          'deployment_user' => 'rmendes'
        }
      end

      it 'should filter out deployment attributes' do
        new_attributes = subject.send(:filter_attributes, @source_attributes)
        new_attributes.size.should == 6

        new_attributes[0].has_key?('AmiId').should be_true
        new_attributes[0]['AmiId'].should == 'ami-7b6a4e3e'
        new_attributes[1].has_key?('AppEnv').should be_true
        new_attributes[1]['AppEnv'].should == 'pod-2-cd-1'
        new_attributes[2].has_key?('MaximumAppInstances').should be_true
        new_attributes[2]['MaximumAppInstances'].should == 1
        new_attributes[3].has_key?('MinimumAppInstances').should be_true
        new_attributes[3]['MinimumAppInstances'].should == 1
        new_attributes[4].has_key?('chef_repo_bucket_prefix').should be_true
        new_attributes[4]['chef_repo_bucket_prefix'].should == 'intu-lc'
        new_attributes[5].has_key?('chef_repo_domain').should be_true
        new_attributes[5]['chef_repo_domain'].should == 'live_community_chef_repo'
      end
    end

    context 'merge_attributes' do
      before do
        @cloned_attributes = [
          { 'AmiId' => 'ami-7b6a4e3e' },
          { 'AppEnv' => 'pod-2-cd-1' },
          { 'MaximumAppInstances' => 1 },
          { 'MinimumAppInstances' => 1 },
          { 'chef_repo_bucket_prefix' => 'intu-lc' },
          { 'chef_repo_domain' => 'live_community_chef_repo' },
          { 'deployment_user' => 'rmendes' }
        ]

        @override_attributes = [
          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
          { 'chef_repo_domain' => 'updated_community_chef_repo' }
        ]
      end

      it 'should merge the override attributes' do
        merged_attributes = subject.send(:merge_attributes, @cloned_attributes, @override_attributes)
        merged_attributes.size.should == 7

        merged_attributes[0].has_key?('AmiId').should be_true
        merged_attributes[0]['AmiId'].should == 'ami-7b6a4e3e'
        merged_attributes[1].has_key?('AppEnv').should be_true
        merged_attributes[1]['AppEnv'].should == 'pod-2-cd-1'
        merged_attributes[2].has_key?('MaximumAppInstances').should be_true
        merged_attributes[2]['MaximumAppInstances'].should == 1
        merged_attributes[3].has_key?('MinimumAppInstances').should be_true
        merged_attributes[3]['MinimumAppInstances'].should == 1
        merged_attributes[4].has_key?('chef_repo_bucket_prefix').should be_true
        merged_attributes[4]['chef_repo_bucket_prefix'].should == 'updated-intu-lc'
        merged_attributes[5].has_key?('chef_repo_domain').should be_true
        merged_attributes[5]['chef_repo_domain'].should == 'updated_community_chef_repo'
        merged_attributes[6].has_key?('deployment_user').should be_true
        merged_attributes[6]['deployment_user'].should == 'rmendes'
      end
    end

    context 'add_attributes' do
      before do
        @cloned_attributes = [
          { 'AmiId' => 'ami-7b6a4e3e' },
          { 'AppEnv' => 'pod-2-cd-1' },
          { 'MaximumAppInstances' => 1 },
          { 'MinimumAppInstances' => 1 },
          { 'chef_repo_bucket_prefix' => 'intu-lc' },
          { 'chef_repo_domain' => 'live_community_chef_repo' },
          { 'deployment_user' => 'rmendes' }
        ]

        @new_attributes = [
          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
          { 'SolrClientTrafficContainer' => 'solr-client-traffic-container' },
          { 'SolrReplicationTrafficContainer' => 'solr-replication-traffic-container' }
        ]
      end

      it 'should add new override attributes' do
        add_attributes = subject.send(:add_attributes, @cloned_attributes, @new_attributes)
        add_attributes.size.should == 2

        add_attributes[0].has_key?('SolrClientTrafficContainer').should be_true
        add_attributes[0]['SolrClientTrafficContainer'].should == 'solr-client-traffic-container'
        add_attributes[1].has_key?('SolrReplicationTrafficContainer').should be_true
        add_attributes[1]['SolrReplicationTrafficContainer'].should == 'solr-replication-traffic-container'
      end

      it 'should return an empty array if there are no new attributes' do
        new_attributes = [
          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
          { 'chef_repo_domain' => 'updated_community_chef_repo' }
        ]

        add_attributes = subject.send(:add_attributes, @cloned_attributes, new_attributes)
        add_attributes.should be_empty
      end
    end

    context 'stack creation' do
      before do
        @options = { :environment => 'my_env',
                     :log_level   => 'debug',
                     :source_name => 'source_stack',
                     :new_name    => 'new_stack',
                     :attributes  => ['chef_repo_bucket_prefix=updated-intu-lc',
                                      'chef_repo_domain=updated_community_chef_repo',
                                      'SolrClientTrafficContainer=solr-client-traffic-container'] }

        @source_stack_stub.stub(:attributes).and_return(
          'AmiId' => 'ami-7b6a4e3e',
          'AppEnv' => 'pod-2-cd-1',
          'MaximumAppInstances' => 1,
          'MinimumAppInstances' => 1,
          'chef_repo_bucket_prefix' => 'intu-lc',
          'chef_repo_domain' => 'live_community_chef_repo',
          'deployment_user' => 'rmendes'
        )
        @source_stack_stub.stub(:template).and_return('foo' => 'bah')
        @new_stack_mock.stub(:attributes).and_return({})
      end

      it 'should create the new stack using the filtered, merged and added attributes' do
        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :source_name, :new_name])
        Trollop.stub(:options).and_return(@options)
        @new_stack_mock.stub(:template).and_return('foo' => 'bah')

        @new_stack_mock.should_receive(:create) do |options|
          options[:attributes].should == [{ 'AmiId' => 'ami-7b6a4e3e' },
                                          { 'AppEnv' => 'pod-2-cd-1' },
                                          { 'MaximumAppInstances' => 1 },
                                          { 'MinimumAppInstances' => 1 },
                                          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
                                          { 'chef_repo_domain' => 'updated_community_chef_repo' },
                                          { 'SolrClientTrafficContainer' => 'solr-client-traffic-container' }]
          options[:template].should match /new_stack_template.json/
        end

        subject.clone
      end

      it 'should create the new stack using a new template' do
        @options[:template] = 'brand_new_template.json'

        subject.should_receive(:valid_options?).
                with(:provided => @options,
                     :required => [:environment, :source_name, :new_name])
        Trollop.stub(:options).and_return(@options)

        @new_stack_mock.should_receive(:create) do |options|
          options[:attributes].should == [{ 'AmiId' => 'ami-7b6a4e3e' },
                                          { 'AppEnv' => 'pod-2-cd-1' },
                                          { 'MaximumAppInstances' => 1 },
                                          { 'MinimumAppInstances' => 1 },
                                          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
                                          { 'chef_repo_domain' => 'updated_community_chef_repo' },
                                          { 'SolrClientTrafficContainer' => 'solr-client-traffic-container' }]
          options[:template].should match /brand_new_template.json/
        end

        subject.clone
      end

      it 'should create the new stack using existing input stack, but cmd line args win' do
        options = { :environment => 'my_env',
                     :input_stack => 'input_stack',
                     :template    => 'brand_new_template.json',
                     :log_level   => 'debug',
                     :source_name => 'source_stack',
                     :new_name    => 'new_stack',
                     :attributes  => ['chef_repo_bucket_prefix=updated-intu-lc',
                                      'chef_repo_domain=updated_community_chef_repo',
                                      'SolrClientTrafficContainer=solr-client-traffic-container', 
                                      'InputStackOutputs=cmdline_value'] }

        input_attributes = [{'InputStackOutputs' => 'inputvalue'}, {'OutputValue' => 'outputs'}]
        input_stub = stub 'input', :map_outputs_from_stacks => input_attributes
        SimpleDeploy::Stack::OutputMapper.stub :new => input_stub

        subject.should_receive(:valid_options?).
                with(:provided => options,
                     :required => [:environment, :source_name, :new_name])
        Trollop.stub(:options).and_return(options)

        @new_stack_mock.stub(:template).and_return('foo' => 'bah')
        @new_stack_mock.should_receive(:create) do |options|
          options[:attributes].should == [{ 'AmiId' => 'ami-7b6a4e3e' },
                                          { 'AppEnv' => 'pod-2-cd-1' },
                                          { 'MaximumAppInstances' => 1 },
                                          { 'MinimumAppInstances' => 1 },
                                          { 'chef_repo_bucket_prefix' => 'updated-intu-lc' },
                                          { 'chef_repo_domain' => 'updated_community_chef_repo' },
                                          { 'InputStackOutputs' => 'cmdline_value' },
                                          { 'OutputValue' => 'outputs'},
                                          { 'SolrClientTrafficContainer' => 'solr-client-traffic-container' }]
                                          
          options[:template].should match /brand_new_template.json/
        end

        subject.clone
      end

    end
  end
end
