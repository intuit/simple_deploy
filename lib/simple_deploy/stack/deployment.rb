require 'capistrano'
require 'capistrano/cli'

require 'simple_deploy/stack/deployment/status'

module SimpleDeploy
  class Stack
    class Deployment
      def initialize(args)
        @config = args[:config]
        @instances = args[:instances]
        @attributes = args[:attributes]
        @environment = args[:environment]
        @ssh_user = args[:ssh_user]
        @ssh_key = args[:ssh_key]
        @stack = args[:stack]
        @name = args[:name]
        @logger = @config.logger
        @region = @config.region(@environment)

        create_deployment
      end

      def execute(force)
        if status.cleared_to_deploy?(force)
          @logger.info 'Starting deployment.'
          set_deploy_command
          @deployment.simpledeploy
          @logger.info 'Deployment complete.'
        else
          @logger.error "Not clear to deploy.  Exiting."
          @logger.error "Use -f to override."
          exit 1
        end
      end

      def ssh
        @instances.map do |i|
          "\nssh -i #{@ssh_key} -l #{@ssh_user} -L 9998:#{i}:22 -N #{@ssh_gateway} &\nssh -p 9998 localhost"
        end
      end

      private

      def set_deploy_command
        cmd = get_artifact_endpoints.any? ? "env " : ""
        get_artifact_endpoints.each_pair do |key,value|
          cmd += "#{key}=#{value} "
        end
        cmd += "PRIMARY_HOST=#{primary_instance} #{deploy_script}"

        @logger.info "Deploy command: '#{cmd}'."
        @deployment.load :string => "task :simpledeploy do
        sudo '#{cmd}'
        end"
      end

      def create_deployment 
        @deployment = Capistrano::Configuration.new :output => @logger
        @deployment.logger.level = @logger.logger_level == 0 ? 3 : 0

        set_ssh_gateway
        set_ssh_user
        set_ssh_options
        set_instances
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

      def set_instances
        @instances.each do |instance| 
          @logger.debug "Deploying to instance #{instance}."
          @deployment.server instance, :instances
        end
      end

      def set_ssh_options
        @logger.debug "Setting key to #{@ssh_key}."
        @deployment.variables[:ssh_options] = { :keys     => @ssh_key, 
                                                :paranoid => false }
      end

      def set_ssh_gateway
        ssh_gateway = @attributes['ssh_gateway']
        if ssh_gateway
          @deployment.set :gateway, ssh_gateway
          @logger.info "Proxying via gateway #{ssh_gateway}."
        else
          @logger.info "Not using an ssh gateway."
        end
      end

      def set_ssh_user
        @logger.debug "Setting user to #{@ssh_user}."
        @deployment.set :user, @ssh_user
      end

      def primary_instance 
        @instances.first
      end

      def deploy_script
        @config.deploy_script
      end

      def status
        @status ||= SimpleDeploy::Stack::Deployment.new :name     => @name,
                                                        :ssh_user => @ssh_user,
                                                        :config   => @config,
                                                        :stack    => @stack
      end

    end
  end
end

