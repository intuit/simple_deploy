module SimpleDeploy
  class Config

    attr_accessor :config, :logger

    def initialize
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.simple_deploy.yml"
      self.config = YAML::load( File.open( config_file ) )
    end

    def artifacts
      config['deploy']['artifacts']
    end

    def keys
      config['deploy']['keys'] ||= "#{env_home}/.ssh/id_rsa"
    end

    def gateway
      config['deploy']['gateway']
    end

    def user
      config['deploy']['user'] ||= "#{env_user}"
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
