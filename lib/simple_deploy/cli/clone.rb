require 'trollop'
require 'tempfile'

module SimpleDeploy
  module CLI
    class Clone
      def clone
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Clone a stack.

simple_deploy clone -s SOURCE_STACK_NAME -n NEW_STACK_NAME -e ENVIRONMENT -a ATTRIB1=VALUE -a ATTRIB2=VALUE

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :source_name, "Stack name for the stack to clone", :type => :string
          opt :new_name, "Stack name for the new stack", :type => :string
          opt :attributes, "= separated attribute and it's value", :type  => :string,
                                                                   :multi => true
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :source_name, :new_name]

        override_attributes = CLI::Shared.parse_attributes :attributes => @opts[:attributes],
                                                           :logger     => logger

        cloned_attributes = filter_attributes source_stack.attributes
        new_attributes = merge_attributes cloned_attributes, override_attributes

        template_file = Tempfile.new("#{@opts[:new_name]}_template.json").path
        File::open(template_file, 'w') { |f| f.write source_stack.template.to_json }

        new_stack.create :attributes => new_attributes,
                         :template   => template_file
      end

      private

      def filter_attributes(source_attributes)
        new_attributes = []

        source_attributes.each_key do |key|
          if key !~ /^deployment/
            new_attributes << { key => source_attributes[key] }
          end
        end

        new_attributes
      end

      def merge_attributes(cloned_attributes, override_attributes)
        cloned_attributes.each do |clone|
          key = clone.keys.first
          override = override_attributes.find { |over| over.has_key? key }
          clone.merge!(override) if override
        end

        cloned_attributes
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
