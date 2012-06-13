module SimpleDeploy
  class Config

    attr_accessor :config

    def initialize
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.simpledeploy.yml"
      self.config = YAML::load( File.open( config_file ) )
    end

    def artifacts
      config['roles']['default']['artifacts']
    end

    def keys
      config['keys']
    end

    def user
      config['user']
    end

    def deploy_script
      config['roles']['default']['deploy_script']
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

  end
end
