require 'trollop'

module SimpleDeploy
  module CLI

    class Deploy
      include Shared

      def deploy
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Execute deployment on given stack(s).

simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT

Using SSH:

Simple deploy defaults your user and key for SSH to your username and your id_rsa key.

If you need to override these because you want to use a different username or you have a different key file,
you can set simple deploy specific environment variables to do the override.

Example 1: Overriding when the command is run.
SIMPLE_DEPLOY_SSH_USER=fred SIMPLE_DEPLOY_SSH_KEY=$HOME/.ssh/id_dsa simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT

Example 2: Overriding them in your shell environment (bash shell used in the example).
export SIMPLE_DEPLOY_SSH_USER=fred
export SIMPLE_DEPLOY_SSH_KEY=$HOME/.ssh/id_dsa
simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT

Using Internal IP for SSH:

Simple deploy defaults to using the public IP when ssh'ng to stacks. This option instructs it
to use the private IP, which is needed when ssh'ng from one stack to another.

simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -i

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
          opt :internal, "Use internal IP for ssh commands"
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        logger = SimpleDeploy.create_logger @opts[:log_level]

        new_attributes = parse_attributes :attributes => @opts[:attributes]

        @opts[:name].each do |name|
          notifier = Notifier.new :stack_name  => name,
                                  :environment => @opts[:environment],
                                  :logger      => logger

          stack = Stack.new :environment => @opts[:environment],
                            :name        => name,
                            :internal    => @opts[:internal]

          proceed = true

          if new_attributes.any?
            rescue_exceptions_and_exit do
              proceed = stack.update :force      => @opts[:force], 
                                     :attributes => new_attributes
            end
          end

          stack.wait_for_stable

          if proceed
            notifier.send_deployment_start_message unless @opts[:quiet]

            result = stack.deploy @opts[:force]

            if result
              notifier.send_deployment_complete_message unless @opts[:quiet]
            else
              logger.error "Deployment to #{name} did not complete succesfully."
              exit 1
            end
          else
            logger.error "Update of #{name} did not complete succesfully."
            exit 1
          end

        end
      end

      def command_summary
        'Execute deployment on given stack(s)'
      end

    end

  end
end
