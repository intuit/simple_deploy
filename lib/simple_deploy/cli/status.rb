require 'trollop'

module SimpleDeploy
  module CLI

    class Status
      include Shared

      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show status of a stack.

simple_deploy status -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        SimpleDeploy.logger @opts[:log_level]
        stack = SimpleDeploy.stack @opts[:name], @opts[:environment]

        rescue_exceptions_and_exit do
          puts stack.status
        end
      end

      def command_summary
        'Show status of a stack'
      end

    end

  end
end
