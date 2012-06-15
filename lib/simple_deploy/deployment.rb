require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Deployment
    def initialize(args)
      @config = args[:config]
      @instances = args[:instances]
      @environment = args[:environment]
      @attributes = args[:attributes]

      @region = @config.region(@environment)
      @deploy_script = @config.deploy_script

      create_deployment
      set_deploy_command
    end

    def execute
      @deployment.simpledeploy
    end

    private

    def set_deploy_command
      cmd = get_artifact_endpoints.any? ? "env " : ""
      get_artifact_endpoints.each_pair do |k,v|
        cmd += "#{k}=#{v} "
      end
      cmd += @deploy_script

      @deployment.load :string => "task :simpledeploy do
      sudo '#{cmd}'
      end"
    end

    def get_artifact_endpoints
      h = {}
      @config.artifacts.each do |a|
        name = a['name']
        endpoint = a['endpoint']
        variable = a['variable']
        artifact = Artifact.new :class => name,
                                :sha => @attributes[name],
                                :region => @region
        h[variable] = artifact.all_endpoints[endpoint]
      end
      h
    end

    def ssh_options
      { 
        :keys => @config.keys,
        :paranoid => false
      }
    end

    def create_deployment 
      @deployment = Capistrano::Configuration.new
      @deployment.set :user, @config.user
      @deployment.variables[:ssh_options] = ssh_options
      @instances.each { |i| @deployment.server i, :instances }
    end
  end
end

