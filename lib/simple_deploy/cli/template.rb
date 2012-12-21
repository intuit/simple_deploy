require 'trollop'

module SimpleDeploy
  module CLI

    class Template
      include Shared

      def show
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show current template for stack.

simple_deploy template -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
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

        jj stack.template
      end

      def command_name
        short_class_name
      end

      def command_summary
        'Show current template for stack'
      end

    end

  end
end
