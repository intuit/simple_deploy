require 'simple_deploy/stack/ssh'

module SimpleDeploy
  class Stack
    class Execute
      def initialize(args)
        @config      = ResourceManager.instance.config
        @instances   = args[:instances]
        @environment = args[:environment]
        @ssh_user    = args[:ssh_user]
        @ssh_key     = args[:ssh_key]
        @stack       = args[:stack]
        @name        = args[:name]
        @logger      = args[:logger]
      end

      def execute(args)
        ssh.execute args
      end

      private

      def ssh
        options = { :instances   => @instances,
                    :environment => @environment,
                    :ssh_user    => @ssh_user,
                    :ssh_key     => @ssh_key,
                    :stack       => @stack,
                    :name        => @name,
                    :logger      => @logger}
        @ssh ||= SimpleDeploy::Stack::SSH.new options
      end

    end
  end
end

