require 'simple_deploy/notifier/campfire'

module SimpleDeploy
  class Notifier
    def initialize(args)
      @stack_name = args[:stack_name]
      @environment = args[:environment]
      @config = Config.new :logger => args[:logger]
      @logger = @config.logger
      @notifications = @config.notifications || {}
    end

    def send_deployment_start_message
      message = "Deployment to #{@stack_name} in #{@config.region @environment} started."
      send message
    end

    def send_deployment_complete_message
      message = "Deployment to #{@stack_name} in #{@config.region @environment} complete."
      attributes = stack.attributes

      if attributes['app_github_url']
        message += " App: #{attributes['app_github_url']}/commit/#{attributes['app']}"
      end

      if attributes['chef_repo_github_url']
        message += " Chef: #{attributes['chef_repo_github_url']}/commit/#{attributes['chef_repo']}"
      end

      send message
    end

    def send(message)
      @notifications.keys.each do |notification|
        case notification
        when 'campfire'
          campfire = Notifier::Campfire.new :stack_name  => @stack_name,
                                            :environment => @environment,
                                            :config      => @config
          campfire.send message
        end
      end
    end

    private

    def stack
      @stack ||= Stack.new :environment => @environment,
                           :name        => @stack_name,
                           :logger      => @logger
    end

  end
end
