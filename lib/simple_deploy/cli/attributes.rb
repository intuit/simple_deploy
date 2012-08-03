require 'trollop'

module SimpleDeploy
  module CLI

    class Attributes
      def show
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Show attributes for stack.

simple_deploy attributes -n STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name to manage", :type => :string
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :name]

        Hash[stack.attributes.sort].each_pair { |k, v| puts "#{k}=#{v}" }
      end

      private
      def config
        @config ||= Config.new.environment @opts[:environment]
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def stack
        @stack = Stack.new :environment => @opts[:environment],
                          :name         => @opts[:name],
                          :config       => config,
                          :logger       => logger
      end

    end

  end
end
