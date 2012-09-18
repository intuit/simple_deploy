require 'stackster'
require 'simple_deploy/stack/deployment'
require 'simple_deploy/stack/stack_attribute_formater'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]
      @config = Config.new :logger => args[:logger]
      @logger = @config.logger
    end

    def create(args)
      attributes = stack_attribute_formater.updated_attributes args[:attributes]
      stack.create :attributes => attributes,
                   :template   => args[:template]
    end

    def update(force, args={})
      if deployment.cleared_to_deploy?(force)
        @logger.info "Updating #{@name}."
        attributes = stack_attribute_formater.updated_attributes args[:attributes]
        stack.update :attributes => attributes
        @logger.info "Update complete for #{@name}."
      end
    end

    def deploy(force = false)
      deployment.create_deployment
      deployment.execute force
    end

    def ssh
      deployment.ssh
    end

    def destroy
      if attributes['protection'] != 'on'
        stack.destroy
        @logger.info "#{@name} destroyed."
        true
      else
        @logger.warn "#{@name} could not be destroyed because it is protected. Run the protect subcommand to unprotect it"
        false
      end
    end

    def events(limit)
      stack.events limit
    end

    def outputs
      stack.outputs
    end

    def resources
      stack.resources
    end

    def instances
      stack.instances.map do |instance| 
        info = instance['instancesSet'].first
        info['vpcId'] ? info['privateIpAddress'] : info['ipAddress']
      end
    end

    def status
      stack.status
    end

    def attributes
      stack.attributes 
    end

    def parameters
      stack.parameters 
    end

    def template
      JSON.parse stack.template
    end
    
    private

    def stack
      stackster_config = @config.environment @environment
      @stack ||= Stackster::Stack.new :environment => @environment,
                                      :name        => @name,
                                      :config      => stackster_config,
                                      :logger      => @logger
    end
    
    def stack_attribute_formater
      @saf ||= StackAttributeFormater.new :config      => @config,
                                          :environment => @environment
    end

    def deployment
      @deployment ||= Stack::Deployment.new :config      => @config,
                                            :environment => @environment,
                                            :name        => @name,
                                            :stack       => stack,
                                            :instances   => instances,
                                            :ssh_user    => ssh_user,
                                            :ssh_key     => ssh_key
    end

    def ssh_key
      ENV['SIMPLE_DEPLOY_SSH_KEY'] ||= "#{ENV['HOME']}/.ssh/id_rsa"
    end

    def ssh_user
      ENV['SIMPLE_DEPLOY_SSH_USER'] ||= ENV['USER']
    end

  end
end
