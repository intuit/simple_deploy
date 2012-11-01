require 'capistrano'
require 'capistrano/cli'

require 'simple_deploy/stack/deployment/status'
require 'simple_deploy/stack/execute'

module SimpleDeploy
  class Stack

    class Deployment

      def initialize(args)
        @config      = args[:config]
        @instances   = args[:instances]
        @environment = args[:environment]
        @ssh_user    = args[:ssh_user]
        @ssh_key     = args[:ssh_key]
        @stack       = args[:stack]
        @name        = args[:name]
        @logger      = @config.logger
        @region      = @config.region @environment
      end

      def execute(force=false)
        wait_for_clear_to_deploy(force)

        if clear_for_deployment?
          status.set_deployment_in_progress

          @logger.info 'Starting deployment.'
          executer.execute :sudo    => true,
                          :command => deploy_command
          @logger.info 'Deployment complete.'

          status.unset_deployment_in_progress
          true
        else
          @logger.error "Not clear to deploy."
          false
        end
      end

      def clear_for_deployment?
        status.clear_for_deployment?
      end

      private

      def wait_for_clear_to_deploy(force)
        if !clear_for_deployment? && force
          clear_deployment_lock true

          Backoff.exp_periods do |p|
            sleep p
            break if clear_for_deployment?
          end
        end
      end

      def clear_deployment_lock(force = false)
        status.clear_deployment_lock force
      end

      def deploy_command
        cmd = 'env '
        get_artifact_endpoints.each_pair do |key,value|
          cmd += "#{key}=#{value} "
        end
        cmd += "PRIMARY_HOST=#{primary_instance} #{deploy_script}"
      end

      def get_artifact_endpoints
        h = {}
        @config.artifacts.each do |artifact|
          variable      = @config.artifact_deploy_variable artifact
          bucket_prefix = attributes["#{artifact}_bucket_prefix"]
          domain        = attributes["#{artifact}_domain"]

          artifact = Artifact.new :name          => artifact,
                                  :id            => attributes[artifact],
                                  :region        => @region,
                                  :domain        => domain,
                                  :bucket_prefix => bucket_prefix

          h[variable] = artifact.endpoints['s3']
        end
        h
      end

      def primary_instance 
        if @stack.instances.any?
          @stack.instances.first['instancesSet'].first['privateIpAddress']
        end
      end

      def deploy_script
        @config.deploy_script
      end

      def executer
        options = { :config      => @config,
                    :instances   => @instances,
                    :environment => @environment,
                    :ssh_user    => @ssh_user,
                    :ssh_key     => @ssh_key,
                    :stack       => @stack,
                    :name        => @name }
        @executer ||= SimpleDeploy::Stack::Execute.new options
      end

      def status
        options = { :name        => @name,
                    :environment => @environment,
                    :ssh_user    => @ssh_user,
                    :config      => @config,
                    :stack       => @stack }
        @status ||= SimpleDeploy::Stack::Deployment::Status.new options
      end

      def attributes
        @stack.attributes
      end

    end

  end
end

