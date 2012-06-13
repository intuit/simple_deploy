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
      @artifacts = get_artifacts_endpoints @config.artifacts
      @deploy_script = @config.deploy_script

      create_deployment
      set_deploy_command
    end

    def set_deploy_command
      cmd = ""
      @artifacts.each_pair do |k,v|
        cmd += "env #{k}=#{v} "
      end
      cmd += @deploy_script

      @deployment.load :string => "task :simpledeploy do
      sudo '#{cmd}'
      end"
    end

    def get_artifacts_endpoints(artifacts)
      h = {}
      @config.artifacts.each do |a|
        h[a['name']] = Artifact.new(:class => a['name'],
                            :sha => @attributes[a['name']],
                            :region => @region).all_endpoints[a['endpoint']]
      end
      h
    end

    def execute
      @deployment.simpledeploy
    end

    def create_deployment 
      ssh_options = {}
      ssh_options[:keys] = @config.keys
      ssh_options[:paranoid] = false

      @deployment = Capistrano::Configuration.new
      @deployment.set :user, @config.user
      @deployment.variables[:ssh_options] = ssh_options
      @instances.each { |i| @deployment.server i, :instances }
    end
  end
end

