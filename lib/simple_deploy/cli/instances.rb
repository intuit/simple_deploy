require 'trollop'

module SimpleDeploy
  module CLI

    class Instances
      include Shared

      def list
        @opts = Trollop::options do
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

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        logger = SimpleDeploy.logger @opts[:log_level]

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name],
                          :internal    => @opts[:internal]

        exit 1 unless stack.exists?

        instances = stack.instances

        if instances.nil? || instances.empty?
          logger.info "Stack '#{@opts[:name]}' does not have any instances."
        else
          puts stack.instances
        end
      end

      def command_summary
        'List instances for stack'
      end

    end

  end
end
