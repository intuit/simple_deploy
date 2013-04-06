require 'singleton'

module SimpleDeploy
  class ResourceManager
    include Singleton

    attr_accessor :environment

    def initialize
    end

    def config(environment = nil, custom_config = {})
      @environment ||= environment
      raise SimpleDeploy::Exceptions::IllegalStateException.new(
        'environment is not defined') unless @environment

      unless @config
        @config = SimpleDeploy::Configuration.configure @environment, custom_config
      end

      @config
    end

    def environments(custom_config = {})
      SimpleDeploy::Configuration.environments custom_config
    end

    def valid_config?
      @config && @config.environment
    end

    def release_config
      @config = nil
    end
  end
end
