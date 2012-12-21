require 'trollop'

module SimpleDeploy
  module CLI

    class List
      include Shared

      def stacks
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List stacks in an environment

simple_deploy list -e ENVIRONMENT

EOS
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :help, "Display Help"
        end

        CLI::Shared.valid_options? :provided => opts,
                                   :required => [:environment]

        config = Config.new.environment opts[:environment]
        stacks = Stackster::StackLister.new(:config => config).all.sort

        logger = SimpleDeployLogger.new :log_level => opts[:log_level]

        stack = Stack.new :environment => opts[:environment],
                          :name        => opts[:name],
                          :config      => config,
                          :logger      => logger
        puts stacks
      end

      def command_name
        short_class_name
      end

      def command_summary
        'List stacks in an environment'
      end

      def environments
        opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List environments

simple_deploy environments

EOS
          opt :help, "Display Help"
        end

        Config.new.environments.keys.each { |e| puts e }
      end

    end

  end
end
