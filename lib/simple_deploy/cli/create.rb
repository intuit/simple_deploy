require 'trollop'

module SimpleDeploy
  module CLI
    class Create
      def create
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Create a new stack.

simple_deploy create -n STACK_NAME -t PATH_TO_TEMPLATE -e ENVIRONMENT -a KEY1=VAL1 -a KEY2=VAL2

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string
          opt :template, "Path to the template file", :type => :string
        end

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        attributes = CLI::Shared.parse_attributes :attributes => opts[:attributes],
                                                  :logger     => logger

        stack = Stack.new :environment => opts[:environment],
                          :name        => name,
                          :config      => config,
                          :logger      => logger

        stack.create :attributes => attributes,
                     :template   => opts[:template]
      end
    end
  end
end
