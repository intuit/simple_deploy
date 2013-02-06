require 'stackster'
require 'simple_deploy/stack/deployment'
require 'simple_deploy/stack/execute'
require 'simple_deploy/stack/stack_attribute_formater'
require 'simple_deploy/stack/stack_output_mapper'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]
      @config = Config.new :logger => args[:logger]
      @logger = @config.logger

      @use_internal_ips = !!args[:internal]
    end

    def create(args)
      attributes = stack_attribute_formater.updated_attributes args[:attributes]
      stack.create :attributes => attributes,
                   :template   => args[:template]
    end

    def update(args)
      if !deployment.clear_for_deployment? && args[:force]
        deployment.clear_deployment_lock true

        Backoff.exp_periods do |p|
          sleep p
          break if deployment.clear_for_deployment?
        end
      end

      if deployment.clear_for_deployment?
        @logger.info "Updating #{@name}."
        attributes = stack_attribute_formater.updated_attributes args[:attributes]
        stack.update :attributes => attributes
        @logger.info "Update complete for #{@name}."
        true
      else
        @logger.info "Not clear to update."
        false
      end
    end

    def deploy(force = false)
      deployment.execute force
    end

    def execute(args)
      executer.execute args
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
        instance['instancesSet'].map do |info|
          if info['vpcId'] || @use_internal_ips
            info['privateIpAddress']
          else
            info['ipAddress']
          end
        end
      end.flatten.compact
    end

    def status
      stack.status
    end

    def wait_for_stable
      stack.wait_for_stable
    end

    def exists?
      stack.status
      true
    rescue Stackster::Exceptions::UnknownStack
      false
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
      @stack ||= Stackster::Stack.new :name        => @name,
                                      :config      => stackster_config,
                                      :logger      => @logger
    end
    
    def stack_attribute_formater
      @saf ||= StackAttributeFormater.new :config          => @config,
                                          :environment     => @environment,
                                          :main_attributes => attributes
    end

    def executer
      @executer ||= Stack::Execute.new :config      => @config,
                                       :environment => @environment,
                                       :name        => @name,
                                       :stack       => stack,
                                       :instances   => instances,
                                       :ssh_user    => ssh_user,
                                       :ssh_key     => ssh_key
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
