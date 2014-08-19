require 'trollop'

require 'simple_deploy/stack/stack_lister'

module SimpleDeploy
  module CLI

    class List
      include Shared

      def stacks
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List stacks in an environment

simple_deploy list -e ENVIRONMENT

EOS
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :read_from_env, "Read credentials and region from environment variables"
          opt :help, "Display Help"
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :read_from_env]

        config_arg = opts[:read_from_env] ? :read_from_env : @opts[:environment]
        SimpleDeploy.create_config config_arg

        SimpleDeploy.logger @opts[:log_level]

        stacks = SimpleDeploy::StackLister.new.all.sort
        puts stacks
      end

      def command_summary
        'List stacks in an environment'
      end

    end

  end
end
