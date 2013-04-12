shared_context "cli logger" do
  before do
    @logger_stub = stub 'logger stub', :debug => true,
                                       :info  => true,
                                       :warn  => true,
                                       :error => true
    SimpleDeploy.stub(:create_logger).and_return(@logger_stub)
    SimpleDeploy.stub(:logger).and_return(@logger_stub)
  end
end

shared_context "double stubbed logger" do
  before do
    @logger_stub = stub 'logger stub', :debug => true,
                                       :info  => true,
                                       :warn  => true,
                                       :error => true
    SimpleDeploy.stub(:logger).and_return(@logger_stub)
  end
end
