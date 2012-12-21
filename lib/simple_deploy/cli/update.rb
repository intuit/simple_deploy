require 'trollop'

module SimpleDeploy
  module CLI

    class Update
      include Shared

      def update
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Update the attributes for one more stacks.

simple_deploy update -n STACK_NAME1 -n STACK_NAME2 -e ENVIRONMENT -a KEY1=VAL1 -a KEY2=VAL2

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :environment, "Set the target environment", :type => :string
          opt :force, "Force an update to proceed"
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string,
                                                         :multi => true
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment, :name]

        config = Config.new.environment opts[:environment]

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        attributes = CLI::Shared.parse_attributes :attributes => opts[:attributes],
                                                  :logger     => logger

        opts[:name].each do |name|
          stack = Stack.new :environment => opts[:environment],
                            :name        => name,
                            :config      => config,
                            :logger      => logger
          stack.update :force => opts[:force], :attributes => attributes
        end
      end

      def command_summary
        'Update the attributes for one more stacks'
      end

    end

  end
end
