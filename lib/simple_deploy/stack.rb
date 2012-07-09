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
      stack.create :attributes => stack_attribute_formater.updated_attributes(args[:attributes]),
                   :template => args[:template]
    end

    def update(args)
      stack.update :attributes => stack_attribute_formater.updated_attributes(args[:attributes])
    end

    # To Do: Abstract deployment into it's own class
    # Pass in required stack objects for attribut mgmt
    def deploy(force = false)
      @logger.info "Checking deployment status."
      if deployment_in_progress?
        @logger.info "Deployment in progress."
        @logger.info "Started by #{attributes['deployment_user']}@#{attributes['deployment_datetime']}."
        if force
          clear_deployment_status
        else
          @logger.error "Exiting due to existing deployment."
          @logger.error "Use -f to override."
          exit 1
        end
      else
        @logger.info "No other deployments in progress."
      end
      set_deployment_in_progress
      deployment.execute
      clear_deployment_status
    end

    def deployment_in_progress?
      attributes['deployment_in_progress'] == 'true'
    end

    def set_deployment_in_progress
      @logger.info "Setting deployment in progress by #{ssh_user}."
      stack.update :attributes => [ { 'deployment_in_progress' => 'true',
                                      'deployment_user'        => ssh_user,
                                      'deployment_datetime'    => Time.now.to_s } ]
    end

    def clear_deployment_status
      @logger.info "Clearing deployment status."
      stack.update :attributes => [ { 'deployment_in_progress' => '' } ]
    end

    def destroy
      stack.destroy
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
      @stack ||= Stackster::Stack.new :environment => @environment,
                                      :name        => @name,
                                      :config      => @config.environment(@environment),
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
