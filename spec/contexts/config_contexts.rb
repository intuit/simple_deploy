shared_context "cli config" do
  before do
    @config_mock = mock 'config mock'
    SimpleDeploy.stub(:create_config).and_return(@config_mock)
    SimpleDeploy.stub(:config).and_return(@config_mock)
  end
end

shared_context "received config" do
  before do
    @config_mock = mock 'config mock'
    SimpleDeploy.should_receive(:config).and_return(@config_mock)
  end
end

shared_context "stubbed config" do
  before do
    @config_mock = mock 'config mock'
    SimpleDeploy.stub(:config).and_return(@config_mock)
  end
end

shared_context "double stubbed config" do |methods_hash|
  before do
    @config_stub = stub 'config stub', methods_hash
    SimpleDeploy.stub(:config).and_return(@config_stub)
  end
end
