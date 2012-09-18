
require 'trollop'

module SimpleDeploy
  module CLI
    class Protect
      def protect
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Protect a stack.

simple_deploy protect -n STACK_NAME -e ENVIRONMENT -a PROTECTION=ON_OFF

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name of stack to protect", :type => :string
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        attributes = CLI::Shared.parse_attributes :attributes => opts[:attributes],
                                                  :logger     => logger

        stack = Stack.new :environment => opts[:environment],
                          :name        => opts[:name],
                          :config      => config,
                          :logger      => logger
        stack.update false, :attributes => attributes
      end
    end
  end
end
