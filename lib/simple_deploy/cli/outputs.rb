require 'trollop'

module SimpleDeploy
  module CLI

    class Outputs
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show outputs of a stack.

simple_deploy outputs -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :as_command_args,
              "Displays the attributes in a format suitable for using on the command line"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'warn'
          opt :name, "Stack name to manage", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        logger = SimpleDeploy.logger @opts[:log_level]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name]

        rescue_exceptions_and_exit do
          @outputs = stack.outputs

          logger.info "No outputs." unless @outputs.any?

          @opts[:as_command_args] ? command_args_output : default_output
        end
      end

      def command_summary
        'Show outputs of a stack'
      end

      private

      def command_args_output
        @outputs.each do |hash|
          print "-a %s=%s " % [hash['OutputKey'], hash['OutputValue']]
        end
        puts ""
      end

      def default_output
        @outputs.each do |hash|
          puts "%s: %s" % [hash['OutputKey'], hash['OutputValue']]
        end
      end

    end
  end
end
