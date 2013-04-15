shared_context "stubbed stack" do |name, environment, options|
  before do
    args = { :name => name, :environment => environment }
    args[:use_internal_ips] = options[:internal] if options && options[:internal]
    @stack_mock = mock 'stack mock', args
    SimpleDeploy.stub(:stack).and_return(@stack_mock)
  end
end

shared_context "double stubbed stack" do |name, environment, options|
  before do
    args = { :name => name, :environment => environment }
    args[:use_internal_ips] = options[:internal] if options && options[:internal]
    @stack_stub = stub 'stack stub', args
    SimpleDeploy.stub(:stack).and_return(@stack_stub)
  end
end

shared_context "clone stack pair" do |source_name, source_env, new_name, new_env|
  before do
    @source_stack_stub = stub 'source stack stub', :name => source_name,
                                                   :environment => source_env
    @new_stack_mock    = mock 'new stack mock', :name => new_name,
                                                :environment => new_env
    SimpleDeploy.stub(:stack).and_return(@source_stack_stub, @new_stack_mock)
  end
end

shared_context "received stack array" do |base_name, env, num_instances|
  before do
    1.upto(num_instances) do |n|
      name = base_name + n.to_s
      stack_mock = mock 'stack mock', :name => name, :environment => env
      self.instance_variable_set(:"@stack_mock#{n}", stack_mock)
      SimpleDeploy.should_receive(:stack).with(name, env).and_return(stack_mock)
    end
  end
end
