require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Stack
    class Deployment
      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @instances = args[:instances]
        @attributes = args[:attributes]
        @environment = args[:environment]
        @ssh_gateway = @attributes['ssh_gateway']
        @ssh_user = args[:ssh_user]
        @ssh_key = args[:ssh_key]

        @region = @config.region(@environment)
        @deploy_script = @config.deploy_script

        create_deployment
      end

      def execute
        set_deploy_command
        @logger.info 'Starting deployment.'
        @deployment.simpledeploy
        @logger.info 'Deployment complete.'
      end

      def ssh
        @instances.map do |i|
          "\nssh -i #{@ssh_key} -l #{@ssh_user} -L 9998:#{i}:22 -N #{@ssh_gateway} &\nssh -p 9998 localhost"
        end
      end

      private

      def set_deploy_command
        cmd = get_artifact_endpoints.any? ? "env " : ""
        get_artifact_endpoints.each_pair do |k,v|
          cmd += "#{k}=#{v} "
        end
        cmd += "PRIMARY_HOST=#{primary_instance} "
        cmd += @deploy_script

        @logger.info "Executing '#{cmd}.'"
        @deployment.load :string => "task :simpledeploy do
        sudo '#{cmd}'
        end"
      end

      def primary_instance 
        @instances.first
      end

      def get_artifact_endpoints
        h = {}
        @config.artifacts.each do |artifact|
          variable = @config.artifact_deploy_variable artifact
          bucket_prefix = @config.artifact_bucket_prefix artifact

          artifact = Artifact.new :name          => artifact,
                                  :id            => @attributes[artifact],
                                  :region        => @region,
                                  :config        => @config,
                                  :bucket_prefix => bucket_prefix
          h[variable] = artifact.endpoints['s3']
        end
        h
      end

      def ssh_options
        @logger.debug "Setting key to #{@ssh_key}."
        { 
          :keys => @ssh_key,
          :paranoid => false
        }
      end

      def create_deployment 
        @deployment = Capistrano::Configuration.new
        if @ssh_user
          @logger.debug "Setting user to #{@ssh_user}."
          @deployment.set :user, @ssh_user
        end

        if @ssh_gateway
          @deployment.set :gateway, @ssh_gateway
          @logger.info "Proxying via gateway #{@ssh_gateway}."
        else
          @logger.info "Not using an ssh gateway."
        end

        @deployment.variables[:ssh_options] = ssh_options
        
        @instances.each do |i| 
          @logger.debug "Deploying to instance #{i}."
          @deployment.server i, :instances
        end
      end

    end
  end
end

