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
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        SimpleDeploy.logger @opts[:log_level]
        @stack = SimpleDeploy.stack @opts[:name], @opts[:environment]

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
