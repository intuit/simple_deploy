require 'trollop'

require 'simple_deploy/stack/stack_lister'

module SimpleDeploy
  module CLI

    class List
      include Shared

      def stacks
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List stacks in an environment

simple_deploy list -e ENVIRONMENT

EOS
          opt :environment, "Set the target environment", :type => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :help, "Display Help"
        end

        valid_options? :provided => @opts,
                       :required => [:environment]

        SimpleDeploy.create_config @opts[:environment]
        SimpleDeploy.logger @opts[:log_level]

        stacks = SimpleDeploy::StackLister.new.all.sort

        stack = Stack.new :environment => @opts[:environment],
                          :name        => @opts[:name]
        puts stacks
      end

      def command_summary
        'List stacks in an environment'
      end

    end

  end
end
