require 'trollop'
require 'tempfile'

module SimpleDeploy
  module CLI

    class Clone
      include Shared

      def clone
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Clone a stack.

simple_deploy clone -s SOURCE_STACK_NAME -n NEW_STACK_NAME -e ENVIRONMENT -a ATTRIB1=VALUE -a ATTRIB2=VALUE

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :source_name, "Stack name for the stack to clone", :type => :string
          opt :new_name, "Stack name for the new stack", :type => :string
          opt :attributes, "= separated attribute and it's value", :type  => :string,
                                                                   :multi => true
          opt :template, "Path to a new template file", :type => :string
        end

        valid_options? :provided => @opts,
                       :required => [:environment, :source_name, :new_name]

        override_attributes = parse_attributes :attributes => @opts[:attributes]

        cloned_attributes = filter_attributes source_stack.attributes
        new_attributes = merge_attributes cloned_attributes, override_attributes
        new_attributes += add_attributes cloned_attributes, override_attributes

        template_file = Tempfile.new("#{@opts[:new_name]}_template.json")
        template_file_path = template_file.path

        if @opts[:template]
          template_file_path = @opts[:template]
        else
          template_file.write source_stack.template.to_json
        end

        rescue_stackster_exceptions_and_exit do
          new_stack.create :attributes => new_attributes,
                           :template   => template_file_path
        end

        template_file.close
      end

      def command_summary
        'Clone a stack'
      end

      private
      def filter_attributes(source_attributes)
        selected = source_attributes.select { |k| k !~ /^deployment/ }
        selected.map { |k,v| { k => v } }
      end

      def merge_attributes(cloned_attributes, override_attributes)
        cloned_attributes.map do |clone|
          key = clone.keys.first
          override = override_attributes.find { |o| o.has_key? key }
          override ? override : clone
        end
      end

      def add_attributes(cloned_attributes, override_attributes)
        override_attributes.map do |override|
          key = override.keys.first
          clone = cloned_attributes.find { |c| c.has_key? key }
          clone ? nil : override
        end.compact
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
