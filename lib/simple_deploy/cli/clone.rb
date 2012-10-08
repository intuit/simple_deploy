require 'trollop'

module SimpleDeploy
  module CLI
    class Clone
      def clone
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Clone a stack.

simple_deploy clone -s SOURCE_STACK_NAME -n NEW_STACK_NAME -e ENVIRONMENT

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :source_name, "Stack name for the stack to clone", :type => :string
          opt :new_name, "Stack name for the new stack", :type => :string
          opt :template, "Path to the template file", :type => :string
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :source_name, :new_name, :template]

        new_attributes = filter_attributes source_stack.attributes

        template_file = File.join '/', 'tmp', "#{@opts[:new_name]}_template.json"
        File::open(template_file, 'w') { |f| f.write source_stack.template.to_json }

        new_stack.create :attributes => new_attributes,
                         :template   => template_file
      end

      private

      def filter_attributes(source_attributes)
        new_attributes = []

        source_attributes.each_key do |key|
          if is_camel_case? key
            new_attributes << { key => source_attributes[key] }
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

      def source_stack
        @source_stack ||= Stack.new :environment => @opts[:environment],
                                    :name        => @opts[:source_name],
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
