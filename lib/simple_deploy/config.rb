module SimpleDeploy
  class Config

    attr_accessor :config, :logger

    def initialize(args = {})
      load_config_file
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

    def artifact_domain(artifact)
      config['artifacts'][artifact]['domain'] ||= artifact
    end

    def artifact_bucket_prefix(artifact)
      config['artifacts'][artifact]['bucket_prefix']
    end

    def deploy_script
      '/opt/intu/admin/bin/configure.sh'
    end

    def environments
      config['environments']
    end

    def environment(name)
      environments[name]
    end

    def region(name)
      environment(name)['region']
    end

    private

    def load_config_file
      config_file = "#{ENV['HOME']}/.simple_deploy.yml"
      self.config = YAML::load( File.open( config_file ) )
    end

    def env_home
      ENV['HOME']
    end

    def env_user
      ENV['USER']
    end

  end
end
