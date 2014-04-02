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

Using Internal / External IPs

simple_deploy defaults to using the public IP when return the IP for stacks in classic, or the private IP when in a VPC.

The internal or external flag forces simple_deploy to use the given IP address.

simple_deploy instances -n STACK_NAME -n STACK_NAME -e ENVIRONMENT -i

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :name, "Stack name to manage", :type => :string
          opt :external, "Return external IP for instances."
          opt :internal, "Return internal IP for instances."
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        logger = SimpleDeploy.logger @opts[:log_level]

        stack = Stack.new :name        => @opts[:name],
                          :environment => @opts[:environment],
                          :external    => @opts[:external],
                          :internal    => @opts[:internal]

        exit 1 unless stack.exists?

        instances = stack.instances

        if instances.nil? || instances.empty?
          logger.info "Stack '#{@opts[:name]}' does not have any instances."
        else
          puts instances
        end
      end

      def command_summary
        'List instances for stack'
      end

    end

  end
end
