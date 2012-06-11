require 'stackster'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_lister'

module SimpleDeploy
  class Stack

    def initialize(args)
      @stack = Stackster::Stack.new :environment => args[:environment],
                                    :name        => args[:name]
      @sr = SimpleDeploy::StackReader.new :environment => args[:environment],
                                          :name        => args[:name]
    end

    def create(args)
      @stack.create :attributes => args[:attributes],
                    :template => args[:template]
    end

    def deploy(args)
      @stack.update :attributes => args[:attributes]
    end

    def destroy
      @stack.destroy
    end

    def events
      @sr.events
    end

    def outputs
      @sr.outputs
    end

    def resources
      @sr.resources
    end

    def instances
      @sr.instances
    end

    def status
      @sr.status
    end

    def attributes
      @sr.attributes 
    end

    def template
      JSON.parse @sr.template
    end

  end
end
