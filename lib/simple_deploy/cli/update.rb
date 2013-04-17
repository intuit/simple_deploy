require 'trollop'

module SimpleDeploy
  module CLI

    class Update
      include Shared

      def update
        @opts = Trollop::options do
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

        valid_options? :provided => @opts,
                       :required => [:environment, :name]

        SimpleDeploy.create_config @opts[:environment]
        SimpleDeploy.logger @opts[:log_level]

        attributes = parse_attributes :attributes => @opts[:attributes]

        @opts[:name].each do |name|
          stack = Stack.new :name        => name,
                            :environment => @opts[:environment]

          rescue_exceptions_and_exit do
            stack.update :force => @opts[:force], :attributes => attributes
          end
        end
      end

      def command_summary
        'Update the attributes for one more stacks'
      end

    end

  end
end
