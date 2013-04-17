require 'simple_deploy/notifier/campfire'

module SimpleDeploy
  class Notifier
    def initialize(args)
      @config = SimpleDeploy.config
      @stack_name = args[:stack_name]
      @environment = args[:environment]
      @notifications = @config.notifications || {}
    end

    def send_deployment_start_message
      message = "Deployment to #{@stack_name} in #{@config.region} started."
      send message
    end

    def send_deployment_complete_message
      message = "Deployment to #{@stack_name} in #{@config.region} complete."
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
                                            :environment => @environment
          campfire.send message
        end
      end
    end

    private 

    def stack
      @stack ||= Stack.new :name        => @stack_name,
                           :environment => @environment
    end
  end
end
