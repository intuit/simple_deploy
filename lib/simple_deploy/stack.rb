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

    # To Do: Abstract deployment into it's own class
    # Pass in required stack objects for attribut mgmt
    def deploy(force = false)
      @logger.info "Deploying to #{@name}."
      @logger.debug "Checking deployment status for #{@name}."
      if deployment_in_progress?
        @logger.info "Deployment in progress for #{@name}."
        @logger.info "Started by #{attributes['deployment_user']}@#{attributes['deployment_datetime']}."
        if force
          @logger.info "Forcing.  Clearing deployment status."
          clear_deployment_status
        else
          @logger.error "Exiting due to existing deployment."
          @logger.error "Use -f to override."
          exit 1
        end
      else
        @logger.debug "No other deployments in progress for #{@name}."
      end
      set_deployment_in_progress
      deployment.execute
      clear_deployment_status
      @logger.info "Deploy completed succesfully for #{@name}."
    end

    def ssh
      deployment.ssh
    end

    def deployment_in_progress?
      attributes['deployment_in_progress'] == 'true'
    end

    def set_deployment_in_progress
      @logger.debug "Setting deployment in progress by #{ssh_user} for #{@name}."
      stack.update :attributes => [ { 'deployment_in_progress' => 'true',
                                      'deployment_user'        => ssh_user,
                                      'deployment_datetime'    => Time.now.to_s } ]
    end

    def clear_deployment_status
      @logger.debug "Clearing deployment in progress for #{@name}."
      stack.update :attributes => [ { 'deployment_in_progress' => '' } ]
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
