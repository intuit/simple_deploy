module SimpleDeploy
  class Config

    attr_accessor :config, :logger

    def initialize(args = {})
      load_config_file
      self.logger = args[:logger] ||= SimpleDeployLogger.new
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.simple_deploy.yml"
      self.config = YAML::load( File.open( config_file ) )
    end

    def artifacts
      config['deploy']['artifacts']
    end

    def deploy_script
      config['deploy']['script']
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

    def artifact_repository
      config['artifact_repository']
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
