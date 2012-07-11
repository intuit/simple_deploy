require 'trollop'
require 'simple_deploy/cli/variables'

module SimpleDeploy
  module CLI
    def self.start
      @opts = Trollop::options do
        version SimpleDeploy::VERSION
        banner <<-EOS

Deploy and manage resources in AWS

simple_deploy environments
simple_deploy list -e ENVIRONMENT
simple_deploy create -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES -t TEMPLATE_PATH
simple_deploy update -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES
simple_deploy deploy -n STACK_NAME -e ENVIRONMENT
simple_deploy ssh -n STACK_NAME -e ENVIRONMENT
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

You must setup a simple_deploy.yaml file in your home directory.  Format as follows:

  artifacts:
    chef_repo:
      domain: app_specific_domain
      bucket_prefix: chef-bucket-prefix
    app:
      domain: app_specific_app
      bucket_prefix: app-bucket-prefix
    cookbooks:
      domain: app_specific_cookbooks
      bucket_prefix: cookbooks-bucket-prefix

  environments:
    preprod_shared_us_west_1:
      access_key: XXXXXXXXXXXXXXXXXXX
      secret_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      region: us-west-1
    infrastructure_us_west_1:
      access_key: XXXXXXXXXXXXXXXXXXX
      secret_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      region: us-west-1
    infrastructure_us_west_2:
      access_key: XXXXXXXXXXXXXXXXXXX
      secret_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      region: us-west-2

Bucket prefixes will append -us-west-1 (or appropriate region) when deploying based on the environment.

For example app-bucket-prefix will be tranlated to app-bucket-prefix-us-west-1.

The domain is the specific domain that is set when the artifact is created by heirloom.

EOS
        opt :help, "Display Help"
        opt :attributes, "= seperated attribute and it's value", :type  => :string,
                                                                 :multi => true
        opt :environment, "Set the target environment", :type => :string
        opt :force, "Force a deployment to proceed"
        opt :limit, "Add limit to results returned by events.", :type    => :integer,
                                                                :default => 3
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

        environments = Config.new.environments
        unless environment_provided?
          puts "\nPlease specify an environment.\n\n"
          environments.keys.each { |e| puts e }
          exit 1
        end

        unless environments.include? @opts[:environment]
          puts "\nEnvironment #{@opts[:environment]} not found.\n"
          exit 1
        end

        @config = Config.new.environment @opts[:environment]
      end

      @stacks = Stackster::StackLister.new(:config => @config).all.sort
      @logger = SimpleDeployLogger.new

      case @cmd
      when 'create', 'delete', 'deploy', 'destroy', 'instances',
           'status', 'attributes', 'events', 'resources',
           'outputs', 'template', 'update', 'parameters',
           'ssh'

        @stack = Stack.new :environment => @opts[:environment],
                           :name        => @opts[:name],
                           :config      => @config,
                           :logger      => @logger
      end

      case @cmd
      when 'attributes'
        @stack.attributes.each_pair { |k, v| puts "#{k}=#{v}" }
      when 'create'
        @stack.create :attributes => attributes,
                      :template => @opts[:template]
        @logger.info "#{@opts[:name]} created."
      when 'delete', 'destroy'
        @stack.destroy
        @logger.info "#{@opts[:name]} destroyed."
      when 'deploy'
        @stack.deploy @opts[:force]
      when 'environments'
        Config.new.environments.keys.each { |e| puts e }
      when 'update'
        @stack.update :attributes => attributes
        @logger.info "#{@opts[:name]} updated."
      when 'instances'
        @stack.instances.each { |s| puts s }
      when 'list'
        puts @stacks
      when 'template'
        jj @stack.template
      when 'outputs', 'resources', 'status', 'parameters'
        puts (@stack.send @cmd.to_sym).to_yaml
      when 'ssh'
        puts @stack.send @cmd.to_sym
      when 'events'
        puts (@stack.events @opts[:limit]).to_yaml
      else
        puts "Unknown command.  Use -h for help."
      end
    end

  end
end
