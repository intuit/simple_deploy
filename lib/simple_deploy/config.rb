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

    def user
      config['user']
    end

    def region
      config['region']
    end

    def script
      config['script']
    end

  end
end
