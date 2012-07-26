require 'stackster'
require 'simple_deploy/stack/deployment'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_lister'
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

    def update(args)
      @logger.info "Updating #{@name}."
      attributes = stack_attribute_formater.updated_attributes args[:attributes]
      stack.update :attributes => attributes
      @logger.info "Update complete for #{@name}."
    end

    def deploy(force = false)
      @logger.info "Deploying to #{@name}."
      deployment.execute(force)
      @logger.info "Deploy completed succesfully for #{@name}."
    end

    def ssh
      deployment.ssh
    end

    def destroy
      stack.destroy
      @logger.info "#{@name} destroyed."
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
      stack.instances.map do |i| 
        if i['instancesSet'].first['privateIpAddress']
          i['instancesSet'].first['privateIpAddress']
        end
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
      environment_config = @config.environment @environment
      @stack ||= Stackster::Stack.new :environment => @environment,
                                      :name        => @name,
                                      :config      => environment_config,
                                      :logger      => @logger
    end
    
    def stack_attribute_formater
      @saf ||= StackAttributeFormater.new :config      => @config,
                                          :environment => @environment
    end

    def deployment
      @deployment ||= Stack::Deployment.new :config      => @config,
                                            :environment => @environment,
                                            :stack       => stack,
                                            :name        => name,
                                            :instances   => instances,
                                            :attributes  => attributes,
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
