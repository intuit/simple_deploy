require 'trollop'

module SimpleDeploy
  module CLI
    class Clone
      def clone
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Clone a stack.

simple_deploy clone -o OLD_STACK_NAME -n NEW_STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :old_name, "Stack name for the stack to clone", :type => :string
          opt :new_name, "Stack name for the new stack", :type => :string
          opt :template, "Path to the template file", :type => :string
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :old_name, :new_name, :template]

        new_attributes = filter_attributes old_stack.attributes
        new_stack.create :attributes => new_attributes,
                         :template   => @opts[:template]
      end

      private

      def filter_attributes(old_attributes)
        new_attributes = {}

        old_attributes.each_key do |key|
          if key == 'Name'
            new_attributes['Name'] = @opts[:new_name]
          elsif is_camel_case? key
            new_attributes[key] = old_attributes[key]
          end
        end

        new_attributes
      end

      def is_camel_case?(attribute_name)
        pattern = /^[a-zA-Z]\w+(?:[A-Z]\w+){1,}/x
        pattern.match(attribute_name.to_s).nil? ? false : true
      end

      def config
        @config ||= Config.new.environment @opts[:environment]
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def old_stack
        @old_stack ||= Stack.new :environment => @opts[:environment],
                               :name        => @opts[:old_name],
                               :config      => config,
                               :logger      => logger
      end

      def new_stack
        @new_stack ||= Stack.new :environment => @opts[:environment],
                               :name        => @opts[:new_name],
                               :config      => config,
                               :logger      => logger
      end
    end
  end
end
