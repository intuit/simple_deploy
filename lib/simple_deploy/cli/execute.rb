require 'trollop'

module SimpleDeploy
  module CLI

    class Execute
      include Shared

      def execute
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Execute command on given stack(s).

simple_deploy execute -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -c "COMMAND"

Using Internal / External IP for SSH:

simple_deploy defaults to using the public IP when ssh'ng to stacks in classic, or the private IP when in a VPC.

The internal or external flag forces simple_deploy to use the given IP address.

simple_deploy execute -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -i

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :command, "Command to execute.", :type => :string
          opt :environment, "Set the target environment", :type => :string
          opt :external, "Use external IP for ssh commands"
          opt :internal, "Use internal IP for ssh commands"
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string,
                                                         :multi => true
          opt :pty, "Set pty to true when executing commands."
          opt :read_from_env, "Read credentials and region from environment variables"
          opt :sudo, "Execute command with sudo"
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name, :read_from_env]

        config_arg = @opts[:read_from_env] ? :read_from_env : @opts[:environment]
        SimpleDeploy.create_config config_arg
        logger = SimpleDeploy.logger @opts[:log_level]

        @opts[:name].each do |name|
          notifier = Notifier.new :stack_name  => name,
                                  :environment => @opts[:environment]

          stack = Stack.new :name        => name,
                            :environment => @opts[:environment],
                            :external    => @opts[:external],
                            :internal    => @opts[:internal]

          begin
            unless stack.execute :command => @opts[:command],
                                 :sudo    => @opts[:sudo],
                                 :pty     => @opts[:pty]
              exit 1
            end
          rescue SimpleDeploy::Exceptions::NoInstances
            logger.error "Stack has no running instances."
            exit 1
          end
        end
      end

      def command_summary
        'Execute command on given stack(s)'
      end

    end

  end
end
