require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Connect
    def initialize(args)
      raise args.inspect
      @config = args[:config]
      @instances = args[:instances]
      @environment = args[:environment]
      @attributes = args[:attributes]

      @region = @config.region @environment
      @artifacts = @config.artifacts
      @deploy_script = @config.deploy_script

      raise artifacts.inspect

      @deploy = deployment
      @deploy.set_deploy_command
    end

    def set_deploy_command
      chef_repo_url = args[:chef_repo_url]
      cookbooks_url = args[:cookbooks_url]
      script = args[:script]

      @config.load :string => "task :simpledeploy do
      sudo 'CHEF_REPO_URL=#{chef_repo_url} COOKBOOKS_URL=#{cookbooks_url} #{script}'
      end"
    end

    def artifacts
      h = {}
      @artifacts.each do |a|
        a['a'] = Artifact.new :class => a,
                              :sha => @attributes[a] 
      end
      h
    end

    def execute
      @deploy.simpledeploy
    end

    def deployment 
      ssh_options = {}
      ssh_options[:keys] = @config.keys
      ssh_options[:paranoid] = false

      deploy = Capistrano::Configuration.new
      deploy.set :user, @config.user
      deploy.variables[:ssh_options] = ssh_options
      @instances.each { |i| deploy.server i, :instances }
      deploy
    end
  end
end

