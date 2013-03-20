module SimpleDeploy
  class Config

    attr_accessor :config, :logger

    def initialize(args = {})
      self.config = args.fetch(:config) { load_config_file }
      self.logger = args[:logger] ||= SimpleDeployLogger.new
    end

    def artifacts
      ['chef_repo', 'cookbooks', 'app']
    end

    def artifact_deploy_variable(artifact)
      name_to_variable_map = { 'chef_repo' => 'CHEF_REPO_URL',
                               'app'       => 'APP_URL',
                               'cookbooks' => 'COOKBOOKS_URL' }
      name_to_variable_map[artifact]
    end

    def artifact_cloud_formation_url(artifact)
      name_to_url_map = { 'chef_repo' => 'ChefRepoURL',
                          'app'       => 'AppArtifactURL',
                          'cookbooks' => 'CookbooksURL' }
      name_to_url_map[artifact]
    end

    def deploy_script
      '/opt/intu/admin/bin/configure.sh'
    end

    def environments
      config['environments']
    end

    def environment(name)
      raise "Environment not found" unless environments.include? name
      environments[name]
    end

    def notifications
      config['notifications']
    end

    def region(name)
      environment(name)['region']
    end

    private

    def load_config_file
      begin
        YAML::load( File.open( config_file ) )
      rescue Errno::ENOENT
        raise "#{config_file} not found"
      # rescue Psych::SyntaxError => e
      #   raise "#{config_file} is corrupt"
      end
    end

    def env_home
      env.load 'HOME'
    end

    def env_user
      env.load 'USER'
    end

    def config_file
      env_config_file || default_config_file
    end

    def env_config_file
      env.load 'SIMPLE_DEPLOY_CONFIG_FILE'
    end

    def default_config_file
      "#{env.load 'HOME'}/.simple_deploy.yml"
    end

    def env
      @env ||= SimpleDeploy::Env.new
    end

  end
end
