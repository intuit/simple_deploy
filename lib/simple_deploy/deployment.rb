require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Deployment
    def initialize(args)
      @config = args[:config]
      @instances = args[:instances]
      @ssh_gateway = args[:ssh_gateway]
      @ssh_user = args[:ssh_user] ||= "#{env_user}"
      @ssh_key = args[:ssh_key] ||= "#{env_home}/.ssh/id_rsa"
      @environment = args[:environment]
      @attributes = args[:attributes]
      @logger = @config.logger

      @region = @config.region(@environment)
      @deploy_script = @config.deploy_script

      create_deployment
      set_deploy_command
    end

    def execute
      @logger.info 'Starting Deployment.'
      @deployment.simpledeploy
    end

    private

    def set_deploy_command
      cmd = get_artifact_endpoints.any? ? "env " : ""
      get_artifact_endpoints.each_pair do |k,v|
        cmd += "#{k}=#{v} "
      end
      cmd += @deploy_script

      @logger.info "Executing '#{cmd}.'"
      @deployment.load :string => "task :simpledeploy do
      sudo '#{cmd}'
      end"
    end

    def get_artifact_endpoints
      h = {}
      @config.artifacts.each do |a|
        name = a['name']
        endpoint = a['endpoint'] ||= 's3'
        variable = a['variable']
        bucket_prefix = a['bucket_prefix']

        artifact = Artifact.new :name          => name,
                                :id            => @attributes[name],
                                :region        => @region,
                                :config        => @config,
                                :bucket_prefix => bucket_prefix
        h[variable] = artifact.endpoints[endpoint]
      end
      h
    end

    def ssh_options
      @logger.info "Setting key to #{@ssh_key}."
      { 
        :keys => @ssh_key,
        :paranoid => false
      }
    end

    def create_deployment 
      @deployment = Capistrano::Configuration.new
      if @ssh_user
        @logger.info "Setting user to #{@ssh_user}."
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
        @logger.info "Adding instance #{i}."
        @deployment.server i, :instances
      end
    end

    private

    def env_home
      ENV['HOME']
    end

    def env_user
      ENV['USER']
    end

  end
end

