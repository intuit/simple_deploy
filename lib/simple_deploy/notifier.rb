require 'simple_deploy/notifier/campfire'

module SimpleDeploy
  class Notifier
    def initialize(args)
      @stack_name = args[:stack_name]
      @environment = args[:environment]
      @config = args[:config]
      @notifications = @config.notifications
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
  end
end
