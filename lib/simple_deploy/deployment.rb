require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Deployment
    def initialize(args)
      @config = args[:config]
      @instances = args[:instances]
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
      @logger.info "Setting key to #{@config.keys}." if @config.keys
      { 
        :keys => @config.keys,
        :paranoid => false
      }
    end

    def create_deployment 
      @deployment = Capistrano::Configuration.new
      if @config.user
        @logger.info "Setting user to #{@config.user}."
        @deployment.set :user, @config.user
      end
      @deployment.set :gateway, @config.gateway if @config.gateway
      @deployment.variables[:ssh_options] = ssh_options
      @logger.info "Proxying via gateway #{@config.gateway}."
      
      @instances.each do |i| 
        @logger.info "Adding instance #{i}."
        @deployment.server i, :instances
      end
    end
  end
end

