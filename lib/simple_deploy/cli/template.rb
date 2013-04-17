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

        SimpleDeploy.create_config @opts[:environment]
        SimpleDeploy.logger @opts[:log_level]
        stack = Stack.new :name        => @opts[:name],
                          :environment => @opts[:environment]

        rescue_exceptions_and_exit do
          raw_json = JSON.parse stack.template
          puts JSON.pretty_generate raw_json
        end
      end

      def command_summary
        'Show current template for stack'
      end

    end

  end
end
