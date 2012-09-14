require 'trollop'

module SimpleDeploy
  module CLI
    class Deploy
      def deploy
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Execute deployment on given stack(s).

simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :environment, "Set the target environment", :type => :string
          opt :force, "Force a deployment to proceed"
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string,
                                                         :multi => true
          opt :quiet, "Quiet, do not send notifications"
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        new_attributes = CLI::Shared.parse_attributes :attributes => opts[:attributes],
                                                      :logger     => logger
        opts[:name].each do |name|
          notifier = Notifier.new :stack_name  => name,
                                  :environment => opts[:environment],
                                  :logger      => logger

          stack = Stack.new :environment => opts[:environment],
                            :name        => name,
                            :logger      => logger

          if new_attributes.any?
            stack.update opts[:force], :attributes => new_attributes
          end

          if stack.deploy opts[:force]
            notifier.send_deployment_complete_message unless opts[:quiet]
          else
            logger.error "Deployment to #{name} did not complete succesfully."
            exit 1
          end

        end
      end
    end
  end
end
