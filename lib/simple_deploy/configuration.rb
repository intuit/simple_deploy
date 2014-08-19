
module SimpleDeploy
  module Configuration
    extend self

    def configure(environment, custom_config = {})
      if custom_config.has_key?(:config)
        env_config    = custom_config[:config]['environments'][environment]
        notifications = custom_config[:config]['notifications']
      else
        env_config, notifications = load_appropriate_config(environment)
      end
      Config.new env_config, notifications
    end

    def environments(custom_config = {})
      raw_config = custom_config.fetch(:config) { load_config_file }
      raw_config['environments']
    end

    private

    def load_appropriate_config(env)
      if env == :read_from_env
        load_config_from_env_vars
      else
        load_config_file env
      end
    end

    def load_config_file(env)
      begin
        config = YAML::load File.open(config_file)
        return config['environments'][env], config['notifications']
      rescue Errno::ENOENT
        raise "#{config_file} not found"
      rescue ArgumentError, Psych::SyntaxError => e
        raise "#{config_file} is corrupt"
      end
    end

    def load_config_from_env_vars
      env_config = {
        'access_key'     => ENV['AWS_ACCESS_KEY_ID'],
        'region'         => ENV['AWS_REGION'],
        'secret_key'     => ENV['AWS_SECRET_ACCESS_KEY'],
        'security_token' => ENV['AWS_SECURITY_TOKEN']
      }

      return env_config, {}
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

    class Config
      attr_reader :environment, :notifications

      def initialize(environment, notifications)
        raise ArgumentError.new("environment must be defined") unless environment

        @environment = environment
        @notifications = notifications
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

      def access_key
        @environment['access_key']
      end

      def secret_key
        @environment['secret_key']
      end

      def security_token
        @environment['security_token']
      end

      def region
        @environment['region']
      end

      def temporary_credentials?
        !!security_token
      end

      private

      def env_home
        env.load 'HOME'
      end

      def env_user
        env.load 'USER'
      end

    end
  end
end
