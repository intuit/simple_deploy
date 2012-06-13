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

    def keys
      config['keys']
    end

    def artifacts
      config['artifacts']
    end

    def user
      config['user']
    end

    def script
      config['script']
    end

    def environments
      config['environments']
    end

    def environment(name)
      environments[name] ||= nil
    end

  end
end
