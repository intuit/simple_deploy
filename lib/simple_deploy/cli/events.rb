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
          opt :read_from_env, "Read credentials and region from environment variables"
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name, :read_from_env]

        config_arg = @opts[:read_from_env] ? :read_from_env : @opts[:environment]
        SimpleDeploy.create_config config_arg
        SimpleDeploy.logger @opts[:log_level]
        stack = Stack.new :name        => @opts[:name],
                          :environment => @opts[:environment]

        rescue_exceptions_and_exit do
          jj stack.events @opts[:count]
        end
      end

      def command_summary
        "Show events for a stack"
      end

    end

  end
end
