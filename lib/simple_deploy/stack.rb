require 'stackster'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_lister'
require 'simple_deploy/stack/stack_attribute_formater'

module SimpleDeploy
  class Stack

    def initialize(args)
      @environment = args[:environment]
      @name = args[:name]
      @config = Config.new
      @config.logger = SimpleDeployLogger.new
    end

    def self.list(args)
      StackLister.new(:config => args[:config]).all
    end

    def create(args)
      saf = StackAttributeFormater.new(:attributes  => args[:attributes],
                                       :config      => @config,
                                       :environment => @environment)
      stack.create :attributes => saf.updated_attributes,
                   :template => args[:template]
    end

    def update(args)
      saf = StackAttributeFormater.new(:attributes  => args[:attributes],
                                       :config      => @config,
                                       :environment => @environment)
      stack.update :attributes => saf.updated_attributes
    end

    def deploy
      deployment = Deployment.new :config      => @config,
                                  :environment => @environment,
                                  :instances   => instances,
                                  :attributes  => attributes,
                                  :ssh_gateway => stack.attributes['ssh_gateway'],
                                  :ssh_user    => ENV['SIMPLE_DEPLOY_USER'],
                                  :ssh_key     => ENV['SIMPLE_DEPLOY_KEY']
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
      stack.instances.map do |i| 
        if i['instancesSet'].first['privateIpAddress']
          i['instancesSet'].first['privateIpAddress']
        end
      end
    end

    def status
      stack.status
    end

    def attributes
      stack.attributes 
    end

    def parameters
      stack.parameters 
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
