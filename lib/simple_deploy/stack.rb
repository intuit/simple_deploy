require 'stackster'
require 'simple_deploy/stack/stack_reader'
require 'simple_deploy/stack/stack_lister'

module SimpleDeploy
  class Stack

    def initialize(args)
      @config = Config.new
      @environment = args[:environment]
      @name = args[:name]
    end

    def create(args)
      stack.create :attributes => args[:attributes],
                    :template => args[:template]
    end

    def update(args)
      stack.update :attributes => args[:attributes]
    end

    def deploy
      connect = Connect.new :keys => @config.keys,
                            :user => @config.user,
                            :instances => instances

      cookbooks = Artifact.new :class => 'cookbooks',
                               :sha => attributes['cookbooks']

      live_community_chef_repo = Artifact.new :class => 'live_community_chef_repo',
                                              :sha => attributes['live_community_chef_repo']

      connect.set_deploy_command :chef_repo_url => live_community_chef_repo.s3_url(@config.region),
                                 :cookbooks_url => cookbooks.http_url(@config.region),
                                 :script => @config.script
      connect.execute
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
                                      :name        => @name
    end

  end
end
