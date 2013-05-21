
require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Update do
  include_context 'cli config'
  include_context 'double stubbed logger'
  include_context 'received stack array', 'my_stack', 'my_env', 1

  describe 'update' do
    before do
      @stack_mock1.stub(:attributes).and_return({})
      @template_body = "{ \"fake_json\" : \"goodness\"}"

      @options = { :environment => 'my_env',
                   :log_level   => 'debug',
                   :name        => ['my_stack1'],
                   :force       => true,
                   :attributes  => ['chef_repo_bucket_prefix=intu-lc'] }

    end

    it "should pass force true" do
      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(@options)

      @stack_mock1.should_receive(:update).with(hash_including(:force => true))

      subject.update
    end

    it "should pass force false" do
      @options[:force] = false

      subject.should_receive(:valid_options?).
              with(:provided => @options,
                   :required => [:environment, :name])

      Trollop.stub(:options).and_return(@options)

      @stack_mock1.should_receive(:update).with(hash_including(:force => false))

      subject.update
    end

    it "should update the template if a new template is provided" do
      @options[:template] = 'brand_new_template.json'

      subject.should_receive(:valid_options?).
        with(:provided => @options,
             :required => [:environment, :name])

      Trollop.stub(:options).and_return(@options)

      IO.should_receive(:read).with('brand_new_template.json').and_return(@template_body)

      @stack_mock1.should_receive(:update).with(hash_including(:template_body => @template_body))
      subject.update
    end
  end
end
