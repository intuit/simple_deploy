require 'trollop'
require 'simple_deploy/cli/variables'

module SimpleDeploy
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS

Deploy and manage resources in AWS

simple_deploy environments
simple_deploy list -e ENVIRONMENT
simple_deploy create -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES -t TEMPLATE_PATH
simple_deploy update -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES
simple_deploy deploy -n STACK_NAME -e ENVIRONMENT
simple_deploy destroy -n STACK_NAME -e ENVIRONMENT
simple_deploy instances -n STACK_NAME -e ENVIRONMENT
simple_deploy status -n STACK_NAME -e ENVIRONMENT
simple_deploy attributes -n STACK_NAME -e ENVIRONMENT
simple_deploy events -n STACK_NAME -e ENVIRONMENT
simple_deploy resources -n STACK_NAME -e ENVIRONMENT
simple_deploy outputs -n STACK_NAME -e ENVIRONMENT
simple_deploy template -n STACK_NAME -e ENVIRONMENT
simple_deploy parameters -n STACK_NAME -e ENVIRONMENT

Attributes are specified as '=' seperated key value pairs.  Multiple can be specified.  For example:

simple_deploy create -t ~/my-template.json -e my-env -n test-stack -a arg1=val1 -a arg2=vol2

EOS
        opt :help, "Display Help"
        opt :attributes, "CSV list of updates attributes", :type  => :string,
                                                           :multi => true
        opt :environment, "Set the target environment", :type => :string
        opt :name, "Stack name to manage", :type => :string
        opt :template, "Path to the template file", :type => :string
      end

      @cmd = ARGV.shift

      unless @cmd
        puts "\nPlease specify a command.\n"
        exit 1
      end

      read_attributes
      
      unless @cmd == 'environments'
        @config = Config.new.environment @opts[:environment]

        unless environment_provided?
          puts "\nPlease specify an environment.\n\n"
          Config.new.environments.keys.each { |e| puts e }
          exit 1
        end
      end

      case @cmd
      when 'create', 'delete', 'deploy', 'destroy', 'instances',
           'status', 'attributes', 'events', 'resources',
           'outputs', 'template', 'update', 'parameters'
        @stack = Stack.new :environment => @opts[:environment],
                           :name        => @opts[:name],
                           :config      => @config
      end

      case @cmd
      when 'attributes'
        @stack.attributes.each_pair { |k, v| puts "#{k}: #{v}" }
      when 'create'
        @stack.create :attributes => attributes,
                      :template => @opts[:template]
        puts "#{@opts[:name]} created."
      when 'delete', 'destroy'
        @stack.destroy
        puts "#{@opts[:name]} destroyed."
      when 'deploy'
        @stack.deploy
        puts "#{@opts[:name]} deployed."
      when 'environments'
        Config.new.environments.keys.each { |e| puts e }
      when 'update'
        @stack.update :attributes => attributes
        puts "#{@opts[:name]} updated."
      when 'instances'
        @stack.instances.each { |s| puts s }
      when 'list'
        puts Stackster::StackLister.new.all
      when 'template'
        jj @stack.template
      when 'events', 'outputs', 'resources', 'status', 'parameters'
        puts (@stack.send @cmd.to_sym).to_yaml
      else
        puts "Unknown command.  Use -h for help."
      end
    end

  end
end
