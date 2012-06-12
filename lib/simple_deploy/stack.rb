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
      @config = Config.new args[:role]
    end

    def create(args)
      @stack.create :attributes => args[:attributes],
                    :template => args[:template]
    end

    def update(args)
      @stack.update :attributes => args[:attributes]
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
