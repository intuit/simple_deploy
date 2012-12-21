require 'trollop'

module SimpleDeploy
  module CLI

    class Destroy
      include Shared

      def destroy
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Destroy a stack.

simple_deploy destroy -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :name]

        config = Config.new.environment @opts[:environment]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :config      => config,
                          :logger      => logger

        stack.destroy ? exit(0) : exit(1)
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'Destroy a stack'
      end

    end

  end
end
