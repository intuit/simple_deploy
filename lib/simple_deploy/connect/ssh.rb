require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Connect
    def initialize(args)
      ssh_options = {}
      ssh_options[:keys] = args[:keys]
      ssh_options[:paranoid] = false

      @config = Capistrano::Configuration.new
      @config.set :user, args[:user]
      @config.variables[:ssh_options] = ssh_options
      args[:instances].each { |i| @config.server i, :instances }
    end

    def set_deploy_command(args)
      chef_repo_url = args[:chef_repo_url]
      cookbooks_url = args[:cookbooks_url]
      script = args[:script]

      @config.load :string => "task :simpledeploy do
      sudo 'CHEF_REPO_URL=#{chef_repo_url} COOKBOOKS_URL=#{cookbooks_url} #{script}'
      end"
    end

    def execute
      @config.simpledeploy
    end
  end
end

