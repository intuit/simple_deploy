require 'trollop'

module SimpleDeploy
  module CLI

    class Execute
      include Shared

      def execute
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Execute command on given stack(s).

simple_deploy execute -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -c "COMMAND"

Using Internal IP for SSH:

Simple deploy defaults to using the public IP when ssh'ng to stacks. This option instructs it
to use the private IP, which is needed when ssh'ng from one stack to another.

simple_deploy deploy -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -i

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :command, "Command to execute.", :type => :string
          opt :environment, "Set the target environment", :type => :string
          opt :internal, "Use internal IP for ssh commands"
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string,
                                                         :multi => true
          opt :sudo, "Execute command with sudo"
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        opts[:name].each do |name|
          notifier = Notifier.new :stack_name  => name,
                                  :environment => opts[:environment],
                                  :logger      => logger

          stack = Stack.new :environment => opts[:environment],
                            :name        => name,
                            :logger      => logger,
                            :internal    => opts[:internal]

          stack.execute :command => opts[:command],
                        :sudo    => opts[:sudo]
        end
      end

      def command_summary
        'Execute command on given stack(s)'
      end

    end

  end
end
