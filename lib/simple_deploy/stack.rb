require 'stackster'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_lister'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]
      @config = Config.new
    end

    def self.list(args)
      StackLister.new(:config => args[:config]).all
    end

    def create(args)
      stack.create :attributes => args[:attributes],
                   :template => args[:template]
    end

    def update(args)
      stack.update :attributes => args[:attributes]
    end

    def deploy
      deployment = Deployment.new :config => @config,
                                  :environment => @environment,
                                  :instances => instances,
                                  :attributes => attributes
      deployment.execute
    end

    def destroy
      stack.destroy
    end

    def events
      stack.events
    end

    def outputs
      stack.outputs
    end

    def resources
      stack.resources
    end

    def instances
      stack.instances_public_ip_addresses
    end

    def status
      stack.status
    end

    def attributes
      stack.attributes 
    end

    def template
      JSON.parse stack.template
    end
    
    private

    def stack
      @stack ||= Stackster::Stack.new :environment => @environment,
                                      :name        => @name,
                                      :config      => @config.environment(@environment)
    end

  end
end
