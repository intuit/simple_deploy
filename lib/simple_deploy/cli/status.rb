require 'trollop'

module SimpleDeploy
  module CLI
    class Status
      def show
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show status of a stack.

simple_deploy status -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
        end

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        stack = Stack.new :environment => opts[:environment],
                          :name        => opts[:name],
                          :config      => config,
                          :logger      => logger

        puts stack.status
      end
    end
  end
end
