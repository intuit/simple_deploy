require 'simple_deploy/stack/deployment'
require 'simple_deploy/stack/execute'
require 'simple_deploy/stack/output_mapper'
require 'simple_deploy/stack/stack_attribute_formater'
require 'simple_deploy/stack/stack_creator'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_updater'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]

      @config = Config.new :logger => args[:logger]
      @logger = @config.logger

      @use_internal_ips = !!args[:internal]
      @entry = Entry.new :name   => @name,
                         :config => @config
    end

    def create(args)
      attributes = stack_attribute_formater.updated_attributes args[:attributes]
      @template_file = args[:template]

      # TODO push this into StackCreator
      begin
        @entry.set_attributes attributes
        stack_creator.create
      rescue Exception => ex
        raise Exceptions::CloudFormationError.new ex.message
      end
      
      # TODO
      #   - examine the returned Excon::Response
      #   - perhaps move AWS::CloudFormation::Error process method to a util
      #   class or module
      @entry.save
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
        @template_body = template

        # TODO push this into StackUpdater
        begin
          @entry.set_attributes attributes
          stack_updater.update_stack_if_parameters_changed attributes
          @logger.info "Update complete for #{@name}."
          true
        rescue Exception => ex
          raise Exceptions::CloudFormationError.new ex.message
        end
        @entry.save
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
    rescue Exceptions::UnknownStack
      false
    end

    def attributes
      stack_reader.attributes
    end

    def parameters
      stack.parameters
    end

    def template
      stack_reader.template
    end

    private

    def stack
      stack_config = @config.environment @environment
      @stack ||= Stack.new :name        => @name,
                           :config      => stack_config,
                           :logger      => @logger
    end

    def stack_creator
      @stack_creator ||= StackCreator.new :name          => @name,
                                          :entry         => @entry,
                                          :template_file => @template_file,
                                          :config        => @config
    end

    def stack_updater
      @stack_updater ||= StackUpdater.new :name          => @name,
                                          :entry         => @entry,
                                          :template_body => @template_body,
                                          :config        => @config
    end

    def stack_reader
      @stack_reader ||= StackReader.new :name   => @name,
                                        :config => @config
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
