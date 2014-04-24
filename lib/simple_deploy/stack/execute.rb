require 'simple_deploy/stack/ssh'

module SimpleDeploy
  class Stack
    class Execute
      def initialize(args)
        @config = SimpleDeploy.config
        @args   = args
      end

      def execute(args)
        ssh.execute args
      end

      private

      def ssh
        @ssh ||= SimpleDeploy::Stack::SSH.new @args
      end

    end
  end
end

