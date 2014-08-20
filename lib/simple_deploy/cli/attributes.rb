require 'trollop'

module SimpleDeploy
  module CLI

    class Attributes
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show attributes for stack.

simple_deploy attributes -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :as_command_args,
              "Displays the attributes in a format suitable for using on the command line"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name to manage", :type => :string
          opt :read_from_env, "Read credentials and region from environment variables"
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name, :read_from_env]

        config_arg = @opts[:read_from_env] ? :read_from_env : @opts[:environment]
        SimpleDeploy.create_config config_arg
        SimpleDeploy.logger @opts[:log_level]
        @stack = Stack.new :name        => @opts[:name],
                           :environment => @opts[:environment]

        @opts[:as_command_args] ? command_args_output : default_output
      end

      def command_summary
        'Show attributes for stack'
      end

      private

      def attribute_data
        rescue_exceptions_and_exit do
          Hash[@stack.attributes.sort]
        end
      end

      def command_args_output
        puts attribute_data.map { |k, v| "-a #{k}=#{v}" }.join(' ')
      end

      def default_output
        attribute_data.each_pair { |k, v| puts "#{k}: #{v}" }
      end
    end

  end
end
