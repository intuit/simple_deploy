require 'trollop'

require 'simple_deploy/cli/shared'

require 'simple_deploy/cli/attributes'
require 'simple_deploy/cli/clone'
require 'simple_deploy/cli/create'
require 'simple_deploy/cli/deploy'
require 'simple_deploy/cli/destroy'
require 'simple_deploy/cli/events'
require 'simple_deploy/cli/execute'
require 'simple_deploy/cli/instances'
require 'simple_deploy/cli/list'
require 'simple_deploy/cli/outputs'
require 'simple_deploy/cli/parameters'
require 'simple_deploy/cli/protect'
require 'simple_deploy/cli/resources'
require 'simple_deploy/cli/ssh'
require 'simple_deploy/cli/status'
require 'simple_deploy/cli/template'
require 'simple_deploy/cli/update'

module SimpleDeploy
  module CLI

    def self.start
      cmd = ARGV.shift

      case cmd
      when 'attributes'
        CLI::Attributes.new.show
      when 'clone'
        CLI::Clone.new.clone
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
      when 'execute'
        CLI::Execute.new.execute
      when 'instances'
        CLI::Instances.new.list
      when 'list'
        CLI::List.new.stacks
      when 'outputs'
        CLI::Outputs.new.show
      when 'parameters'
        CLI::Parameters.new.show
      when 'protect'
        CLI::Protect.new.protect
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
      when '-h'
        usage
      when '-v'
        puts SimpleDeploy::VERSION
      else
        puts "Unknown command: '#{cmd}'."
        puts ''
        usage
        exit 1
      end
    end

    def self.usage
      puts 'Usage: simple_deploy command'
      puts ''
      puts 'Append -h for help on specific subcommand.'
      puts ''

      puts 'Commands:'
      commands.each do |cmd|
        $stdout.printf "    %-#{length_of_longest_command}s      %s\n",
                       cmd.command_name,
                       cmd.command_summary
      end
    end

    def self.commands
      return @commands if @commands
      klasses   = SimpleDeploy::CLI.constants.reject { |c| c == :Shared }
      @commands = klasses.map { |klass| SimpleDeploy::CLI.const_get(klass).new }
    end

    def self.length_of_longest_command
      commands.map { |c| c.command_name.length }.max
    end

  end
end
