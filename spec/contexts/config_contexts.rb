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
