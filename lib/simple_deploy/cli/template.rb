require 'trollop'

module SimpleDeploy
  module CLI

    class Template
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show current template for stack.

simple_deploy template -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        config = SimpleDeploy.create_config @opts[:environment]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :logger      => logger

        rescue_exceptions_and_exit do
          raw_json = JSON.parse stack.template
          puts JSON.pretty_generate raw_json
        end
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'Show current template for stack'
      end

    end

  end
end
