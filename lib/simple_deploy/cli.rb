require 'trollop'

require 'simple_deploy/cli/shared'

require 'simple_deploy/cli/attributes'
require 'simple_deploy/cli/create'
require 'simple_deploy/cli/deploy'
require 'simple_deploy/cli/events'
require 'simple_deploy/cli/instances'
require 'simple_deploy/cli/list'
require 'simple_deploy/cli/outputs'
require 'simple_deploy/cli/parameters'
require 'simple_deploy/cli/resources'
require 'simple_deploy/cli/ssh'
require 'simple_deploy/cli/status'
require 'simple_deploy/cli/template'
require 'simple_deploy/cli/update'

module SimpleDeploy
  module CLI
    def self.start
      cmd = ARGV.shift

      unless cmd
        puts "\nPlease specify a command.\n"
        exit 1
      end

      case cmd
      when 'attributes'
        CLI::Attributes.new.show
      when 'create'
        CLI::Create.new.create
      when 'destroy', 'delete'
        CLI::Destroy.new.destroy
      when 'deploy'
        CLI::Deploy.new.deploy
      when 'environments'
        CLI::List.new.environments
      when 'events'
        CLI::Events.new.show
      when 'instances'
        CLI::Instances.new.list
      when 'list'
        CLI::List.new.stacks
      when 'outputs'
        CLI::Outputs.new.show
      when 'parameters'
        CLI::Parameters.new.show
      when 'resources'
        CLI::Resources.new.show
      when 'status'
        CLI::Status.new.show
      when 'template'
        CLI::Template.new.show
      when 'ssh'
        CLI::SSH.new.show
      when 'update'
        CLI::Update.new.update
      else
        puts "Unknown command: '#{cmd}'."
        puts "simple_deploy [attributes|create|destroy|environments|events|instances|list|template|outputs|parameters|resources|ssh|status|update]"
        puts "Append -h for help on specific subcommand."
      end
    end

  end
end
