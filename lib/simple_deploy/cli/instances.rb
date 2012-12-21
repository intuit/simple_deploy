require 'trollop'

module SimpleDeploy
  module CLI
    class Instances
      def list
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List instances for stack.

simple_deploy instances -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
          opt :internal, "Use internal IP for ssh commands"
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        stack = Stack.new :environment => opts[:environment],
                          :name        => opts[:name],
                          :config      => config,
                          :logger      => logger,
                          :internal    => opts[:internal]

        exit 1 unless stack.exists?

        instances = stack.instances

        if instances.nil? || instances.empty?
          logger.info "Stack '#{opts[:name]}' does not have any instances."
        else
          puts stack.instances
        end
      end
    end
  end
end
