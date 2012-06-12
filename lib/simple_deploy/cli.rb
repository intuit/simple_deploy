require 'trollop'
require 'simple_deploy/cli/variables'

module SimpleDeploy
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS

Deploy and manage resources in AWS

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

EOS
        opt :help, "Display Help"
        opt :attributes, "CSV list of updates attributes", :type => :string
        opt :environment, "Set the target environment", :type => :string
        opt :name, "Stack name to manage", :type => :string
        opt :template, "Path to the template file", :type => :string
      end

      @cmd = ARGV.shift

      unless @cmd
        puts "Please specify a command."
        exit 1
      end

      read_attributes
      
      unless @cmd == 'artifacts'
        unless environment_provided?
          puts "Please specify an environment."
          exit 1
        end
      end

      case @cmd
      when 'create', 'delete', 'deploy', 'destroy', 'instances',
           'status', 'attributes', 'events', 'resources',
           'outputs', 'template', 'update'
        @stack = Stack.new :environment => @opts[:environment],
                           :name        => @opts[:name]
      end

      case @cmd
      when 'attributes'
        @stack.attributes.each_pair { |k, v| puts "#{k}: #{v}" }
      when 'artifacts'
        puts Artifact.list.to_yaml
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
      when 'update'
        @stack.update :attributes => attributes
        puts "#{@opts[:name]} updated."
      when 'instances'
        @stack.instances.each { |s| puts s }
      when 'list'
        s = StackLister.new @opts[:environment]
        puts s.all
      when 'template'
        jj @stack.template
      when 'events', 'outputs', 'resources', 'status'
        puts (@stack.send @cmd.to_sym).to_yaml
      else
        puts "Unknown command.  Use -h for help."
      end
    end

  end
end
