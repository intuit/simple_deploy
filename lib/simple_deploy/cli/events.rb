require 'trollop'

module SimpleDeploy
  module CLI

    class Events
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show events for stack.

simple_deploy attributes -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :count, "Count of events returned.", :type    => :integer,
                                                   :default => 3
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        config = ResourceManager.instance.config @opts[:environment]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :logger      => logger

        rescue_exceptions_and_exit do
          jj stack.events @opts[:count]
        end
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        "Show events for a stack"
      end

    end

  end
end
