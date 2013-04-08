require 'simple_deploy/stack/deployment'
require 'simple_deploy/stack/execute'
require 'simple_deploy/stack/output_mapper'
require 'simple_deploy/stack/stack_attribute_formater'
require 'simple_deploy/stack/stack_creator'
require 'simple_deploy/stack/stack_destroyer'
require 'simple_deploy/stack/stack_formatter'
require 'simple_deploy/stack/stack_lister'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_updater'
require 'simple_deploy/stack/status'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]

      @config = ResourceManager.instance.config
      @logger = args[:logger]

      @use_internal_ips = !!args[:internal]
      @entry = Entry.new :name => @name, :logger => @logger
    end

    def create(args)
      attributes = stack_attribute_formater.updated_attributes args[:attributes]
      @template_file = args[:template]

      @entry.set_attributes attributes
      stack_creator.create
      
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

        @entry.set_attributes attributes
        stack_updater.update_stack_if_parameters_changed attributes
        @logger.info "Update complete for #{@name}."

        @entry.save
        true
      else
        @logger.info "Not clear to update."
        false
      end
    end

    def in_progress_update(args)
      if args[:caller] && args[:caller].kind_of?(Stack::Deployment::Status)
        @logger.info "Updating #{@name}."
        attributes = stack_attribute_formater.updated_attributes args[:attributes]
        @template_body = template

        @entry.set_attributes attributes
        stack_updater.update_stack_if_parameters_changed attributes
        @logger.info "Update complete for #{@name}."

        @entry.save
        true
      else
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
        stack_destroyer.destroy
        @entry.delete_attributes
        @logger.info "#{@name} destroyed."
        true
      else
        @logger.warn "#{@name} could not be destroyed because it is protected. Run the protect subcommand to unprotect it"
        false
      end
    end

    def events(limit)
      stack_reader.events limit
    end

    def outputs
      stack_reader.outputs
    end

    def resources
      stack_reader.resources
    end

    def instances
      stack_reader.instances.map do |instance| 
        instance['instancesSet'].map do |info|
          if info['vpcId'] || @use_internal_ips
            info['privateIpAddress']
          else
            info['ipAddress']
          end
        end
      end.flatten.compact
    end

    def raw_instances
      stack_reader.instances
    end

    def status
      stack_reader.status
    end

    def wait_for_stable
      stack_status.wait_for_stable
    end

    def exists?
      status
      true
    rescue Exceptions::UnknownStack
      false
    end

    def attributes
      stack_reader.attributes
    end

    def parameters
      stack_reader.parameters
    end

    def template
      stack_reader.template
    end

    private

    def stack_creator
      @stack_creator ||= StackCreator.new :name          => @name,
                                          :entry         => @entry,
                                          :template_file => @template_file,
                                          :logger        => @logger
    end

    def stack_updater
      @stack_updater ||= StackUpdater.new :name          => @name,
                                          :entry         => @entry,
                                          :template_body => @template_body,
                                          :logger        => @logger
    end

    def stack_reader
      @stack_reader ||= StackReader.new :name   => @name,
                                        :logger => @logger
    end

    def stack_destroyer
      @stack_destroyer ||= StackDestroyer.new :name   => @name,
                                              :logger => @logger
    end

    def stack_status
      @status ||= Status.new :name   => @name,
                             :logger => @logger
    end

    def stack_attribute_formater
      @saf ||= StackAttributeFormater.new :main_attributes => attributes,
                                          :logger          => @logger
    end

    def executer
      @executer ||= Stack::Execute.new :logger      => @logger,
                                       :environment => @environment,
                                       :name        => @name,
                                       :stack       => self,
                                       :instances   => instances,
                                       :ssh_user    => ssh_user,
                                       :ssh_key     => ssh_key
    end

    def deployment
      @deployment ||= Stack::Deployment.new :logger      => @logger,
                                            :environment => @environment,
                                            :name        => @name,
                                            :stack       => self,
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
