require 'trollop'

module SimpleDeploy
  module CLI

    class Create
      include Shared

      def create
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Create a new stack.

simple_deploy create -n STACK_NAME -t PATH_TO_TEMPLATE -e ENVIRONMENT -a KEY1=VAL1 -a KEY2=VAL2

EOS
          opt :help, "Display Help"
          opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :stacks, "Read outputs from existing stacks", :type  => :string,
                                                            :multi => true
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stack to deploy", :type => :string
          opt :template, "Path to the template file", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name, :template]

        config = Config.new.environment @opts[:environment]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :config      => config,
                          :logger      => logger

        provided_attributes = parse_attributes :attributes => @opts[:attributes]

        attributes = merger.merge :attributes  => provided_attributes,
                                  :config      => @config,
                                  :logger      => @logger,
                                  :environment => @opts[:environment],
                                  :stacks      => @opts[:stacks],
                                  :template    => @opts[:template]

        rescue_stackster_exceptions_and_exit do
          stack.create :attributes => attributes,
                       :template   => @opts[:template]
        end
      end

      def merger
        SimpleDeploy::CLI::Misc::AttributeMerger.new
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'Create a new stack'
      end

    end

  end
end
