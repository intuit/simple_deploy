require 'trollop'

module SimpleDeploy
  module CLI

    class Environments
      include Shared

      def environments
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

List environments

simple_deploy environments

EOS
          opt :help, "Display Help"
        end

        Config.new.environments.keys.each { |e| puts e }
      end

      def command_summary
        'List environments'
      end

    end

  end
end
