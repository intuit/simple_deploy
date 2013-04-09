
module SimpleDeploy
  module Configuration
    extend self

    def configure(environment, custom_config = {})
      raw_config = custom_config.fetch(:config) { load_config_file }
      Config.new raw_config['environments'][environment],
                 raw_config['notifications']
    end

    def environments(custom_config = {})
      raw_config = custom_config.fetch(:config) { load_config_file }
      raw_config['environments']
    end

    private

    def load_config_file
      begin
        YAML::load File.open(config_file)
      rescue Errno::ENOENT
        raise "#{config_file} not found"
      rescue ArgumentError, Psych::SyntaxError => e
        raise "#{config_file} is corrupt"
      end
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

      def region
        @environment['region']
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
