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
      connect = Connect.new :keys => '/Users/bweaver/.ssh/keys/lc/bweaver-lc-share-preprod.pem',
                            :user => 'ec2-user',
                            :instances => instances

        cookbooks = Artifact.new :class => 'cookbooks',
                                 :sha => attributes['cookbooks']
        live_community_chef_repo = Artifact.new :class => 'live_community_chef_repo',
                                                :sha => attributes['live_community_chef_repo']
        raise cookbooks.s3_url('us-west-1')

      connect.set_deploy_command :chef_repo_url => 's3://intu-lc-us-west-1/live_community_chef_repo/5ed15da9b4a11272dc661170bfa3ec66b1fc9045.tar.gz',
                                 :cookbooks_url => 'http://s3-us-west-1.amazonaws.com/intu-artifacts-us-west-1/cookbooks/0ea7de4d64505774d6c1668127c95a45140615b4.tar.gz',
                                 :script => '/opt/intu/admin/bin/configure.sh'
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
