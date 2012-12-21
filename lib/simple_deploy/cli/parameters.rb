require 'trollop'

module SimpleDeploy
  module CLI

    class Parameters
      include Shared

      def show
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show parameters of a stack.

simple_deploy parameters -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'warn'
          opt :name, "Stack name to manage", :type => :string
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        stack = Stack.new :environment => opts[:environment],
                          :name        => opts[:name],
                          :config      => config,
                          :logger      => logger

        puts stack.parameters
      end

      def command_name
        short_class_name
      end

      def command_summary
        'Show parameters of a stack'
      end

    end

  end
end
