
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Update do
  include_context 'cli config'
  include_context 'cli logger'

  describe 'update' do
    before do
      @stack   = stub :attributes => {}
    end

    it "should pass force true" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => true,
                  :attributes  => ['chef_repo_bucket_prefix=intu-lc'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :name        => 'my_stack').
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => true))

      subject.update
    end

    it "should pass force false" do
      options = { :environment => 'my_env',
                  :log_level   => 'debug',
                  :name        => ['my_stack'],
                  :force       => false,
                  :attributes  => ['chef_repo_bucket_prefix=intu-lc'] }

      subject.should_receive(:valid_options?).
              with(:provided => options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(options)

      SimpleDeploy::Stack.should_receive(:new).
                          with(:environment => 'my_env',
                               :name        => 'my_stack').
                          and_return(@stack)

      @stack.should_receive(:update).with(hash_including(:force => false))

      subject.update
    end
  end
end
